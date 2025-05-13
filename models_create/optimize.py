import json
import os
import operator

def optimize_models(input_dir, min_unigram_count=5, min_bigram_count=3, 
                   min_trigram_count=2, min_cap_count=2, top_k=20000):
    """
    Optimize n-gram models for mobile usage by:
    1. Removing rare words and n-grams
    2. Limiting the vocabulary size
    3. Limiting the number of predictions per context
    4. Preserving important capitalization patterns
    """
    print("Optimizing models for mobile usage...")
    
    # Load original models
    with open(os.path.join(input_dir, 'unigrams.json'), 'r', encoding='utf-8') as f:
        unigrams = json.load(f)
    
    with open(os.path.join(input_dir, 'bigrams.json'), 'r', encoding='utf-8') as f:
        bigrams = json.load(f)
    
    with open(os.path.join(input_dir, 'trigrams.json'), 'r', encoding='utf-8') as f:
        trigrams = json.load(f)
        
    with open(os.path.join(input_dir, 'completions.json'), 'r', encoding='utf-8') as f:
        completions = json.load(f)
        
    with open(os.path.join(input_dir, 'cap_patterns.json'), 'r', encoding='utf-8') as f:
        cap_patterns = json.load(f)
    
    # Filter and limit vocabulary size
    sorted_unigrams = sorted(unigrams.items(), key=operator.itemgetter(1), reverse=True)
    filtered_unigrams = {word: count for word, count in sorted_unigrams[:top_k] 
                        if count >= min_unigram_count}
    
    # Filter bigrams
    filtered_bigrams = {}
    for first_word, next_words in bigrams.items():
        if first_word in filtered_unigrams:
            filtered_next = {w: c for w, c in next_words.items() 
                           if w in filtered_unigrams and c >= min_bigram_count}
            if filtered_next:
                sorted_next = sorted(filtered_next.items(), key=operator.itemgetter(1), reverse=True)
                filtered_bigrams[first_word] = dict(sorted_next[:10])
    
    # Filter trigrams
    filtered_trigrams = {}
    for word_pair, next_words in trigrams.items():
        w1, w2 = word_pair.split()
        if w1 in filtered_unigrams and w2 in filtered_unigrams:
            filtered_next = {w: c for w, c in next_words.items() 
                           if w in filtered_unigrams and c >= min_trigram_count}
            if filtered_next:
                sorted_next = sorted(filtered_next.items(), key=operator.itemgetter(1), reverse=True)
                filtered_trigrams[word_pair] = dict(sorted_next[:10])
    
    # Filter completion predictions
    filtered_completions = {}
    for prefix, words in completions.items():
        if len(prefix) >= 2:  # Only keep prefixes of length 2 or more
            filtered_next = {w: c for w, c in words.items() 
                           if w in filtered_unigrams and c >= min_bigram_count}
            if filtered_next:
                sorted_next = sorted(filtered_next.items(), key=operator.itemgetter(1), reverse=True)
                filtered_completions[prefix] = dict(sorted_next[:10])
    
    # Filter capitalization patterns
    filtered_cap_patterns = {}
    for word, patterns in cap_patterns.items():
        if word in filtered_unigrams:  # Only keep patterns for words in our vocabulary
            filtered_patterns = {form: count for form, count in patterns.items() 
                              if count >= min_cap_count}
            if filtered_patterns:
                sorted_patterns = sorted(filtered_patterns.items(), key=operator.itemgetter(1), reverse=True)
                filtered_cap_patterns[word] = dict(sorted_patterns[:3])  # Keep top 3 patterns
    
    # Calculate sizes
    original_size = sum(len(json.dumps(x, ensure_ascii=False)) for x in 
                       [unigrams, bigrams, trigrams, completions, cap_patterns]) / (1024 * 1024)
    
    optimized_size = sum(len(json.dumps(x, ensure_ascii=False)) for x in 
                        [filtered_unigrams, filtered_bigrams, filtered_trigrams, 
                         filtered_completions, filtered_cap_patterns]) / (1024 * 1024)
    
    # Save optimized models
    output_dir = os.path.join(input_dir, 'optimized')
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)
    
    # Convert and save probability models
    convert_to_probabilities(output_dir, filtered_unigrams, filtered_bigrams, 
                           filtered_trigrams, filtered_completions, filtered_cap_patterns)
    
    print(f"Original model size: {original_size:.2f} MB")
    print(f"Optimized model size: {optimized_size:.2f} MB")
    print(f"Size reduction: {100 * (1 - optimized_size/original_size):.2f}%")
    print(f"Vocabulary size reduced from {len(unigrams)} to {len(filtered_unigrams)} words")
    print(f"Capitalization patterns reduced from {len(cap_patterns)} to {len(filtered_cap_patterns)}")
    print(f"Optimized models saved to: {output_dir}")

def convert_to_probabilities(output_dir, unigrams, bigrams, trigrams, completions, cap_patterns):
    """Convert raw counts to probability distributions"""
    # Calculate total word count
    total_words = sum(unigrams.values())
    
    # Convert unigrams to probabilities
    unigram_probs = {word: count/total_words for word, count in unigrams.items()}
    
    # Convert bigrams to probabilities
    bigram_probs = {}
    for first_word, next_words in bigrams.items():
        first_word_count = unigrams.get(first_word, 0)
        if first_word_count > 0:
            bigram_probs[first_word] = {
                next_word: count/first_word_count 
                for next_word, count in next_words.items()
            }
    
    # Convert trigrams to probabilities
    trigram_probs = {}
    for word_pair, next_words in trigrams.items():
        w1, w2 = word_pair.split()
        bigram_count = bigrams.get(w1, {}).get(w2, 0)
        if bigram_count > 0:
            trigram_probs[word_pair] = {
                next_word: count/bigram_count 
                for next_word, count in next_words.items()
            }
    
    # Convert completion model to probabilities
    completion_probs = {}
    for prefix, words in completions.items():
        total_completions = sum(words.values())
        if total_completions > 0:
            completion_probs[prefix] = {
                word: count/total_completions 
                for word, count in words.items()
            }
    
    # Convert capitalization patterns to probabilities
    cap_pattern_probs = {}
    for word, patterns in cap_patterns.items():
        total_occurrences = sum(patterns.values())
        if total_occurrences > 0:
            cap_pattern_probs[word] = {
                form: count/total_occurrences 
                for form, count in patterns.items()
            }
    
    # Save all probability models
    with open(os.path.join(output_dir, 'unigram_probs.json'), 'w', encoding='utf-8') as f:
        json.dump(unigram_probs, f, ensure_ascii=False)
    
    with open(os.path.join(output_dir, 'bigram_probs.json'), 'w', encoding='utf-8') as f:
        json.dump(bigram_probs, f, ensure_ascii=False)
    
    with open(os.path.join(output_dir, 'trigram_probs.json'), 'w', encoding='utf-8') as f:
        json.dump(trigram_probs, f, ensure_ascii=False)
    
    with open(os.path.join(output_dir, 'completion_probs.json'), 'w', encoding='utf-8') as f:
        json.dump(completion_probs, f, ensure_ascii=False)
    
    with open(os.path.join(output_dir, 'cap_patterns_probs.json'), 'w', encoding='utf-8') as f:
        json.dump(cap_pattern_probs, f, ensure_ascii=False)

if __name__ == "__main__":
    input_directory = "models"
    
    optimize_models(
        input_directory,
        min_unigram_count=5,
        min_bigram_count=3,
        min_trigram_count=2,
        min_cap_count=2,
        top_k=20000
    )