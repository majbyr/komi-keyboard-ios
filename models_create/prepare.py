import re
import json
import os
from collections import defaultdict, Counter

def is_abbreviation(token):
    """Check if token is likely an abbreviation"""
    # All uppercase and at least 2 letters
    return token.isupper() and len(token) >= 2

def is_proper_noun(token, position_first=False):
    """Check if token is likely a proper noun"""
    # First letter capital, rest lowercase, and not at start of sentence
    return (token[0].isupper() and 
            token[1:].islower() and 
            len(token) > 1 and 
            not position_first)

def is_mostly_caps(text):
    """Check if more than 50% of letters in text are uppercase"""
    letters = [c for c in text if c.isalpha()]
    if not letters:
        return False
    uppercase_count = sum(1 for c in letters if c.isupper())
    return uppercase_count / len(letters) > 0.5

def preprocess_corpus(input_file, output_dir):
    """
    Preprocess the corpus file and create n-gram and completion models with capitalization patterns
    
    Args:
        input_file: Path to the corpus text file
        output_dir: Directory to save processed model files
    """
    print(f"Processing corpus file: {input_file}")
    
    # Create output directory if it doesn't exist
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)
    
    # Counters for various models
    unigrams = Counter()
    bigrams = defaultdict(Counter)
    trigrams = defaultdict(Counter)
    completions = defaultdict(Counter)
    cap_patterns = defaultdict(Counter)  # Track capitalization patterns
    
    total_sentences = 0
    sentence_start = True
    
    with open(input_file, 'r', encoding='utf-8') as f:
        for line in f:
            # Keep original line for capitalization
            original_line = line.strip()
            if not original_line:
                sentence_start = True
                continue
            
            # Skip lines that are mostly uppercase (likely headers or non-natural text)
            if is_mostly_caps(original_line):
                sentence_start = True
                continue
            
            # Tokenize preserving case
            tokens = re.sub(r'[^\w\s]', '', original_line).split()
            if len(tokens) < 1:
                continue
            
            # Process tokens with position awareness
            for i, token in enumerate(tokens):
                lower_token = token.lower()
                
                # Count unigrams (lowercase)
                unigrams[lower_token] += 1
                
                # Track special capitalization patterns
                # Skip first word of sentence for capitalization learning
                if is_abbreviation(token):
                    # Force uppercase for abbreviations
                    cap_patterns[lower_token][token.upper()] += 3  # Higher weight
                elif is_proper_noun(token) and not (i == 0 and sentence_start):
                    # Only track capitalization for non-sentence-initial words
                    cap_patterns[lower_token][token.capitalize()] += 2  # Medium weight
                    cap_patterns[lower_token][lower_token] += 1       # Lower weight
                elif i == 0 and sentence_start:
                    # Don't learn capitalization from sentence-initial words
                    pass
                else:
                    cap_patterns[lower_token][token] += 1
                
                # Store completions preserving case, but don't learn from sentence start
                for j in range(1, len(lower_token)):
                    prefix = lower_token[:j]
                    if is_abbreviation(token):
                        completions[prefix][token.upper()] += 2
                    elif not (i == 0 and sentence_start):
                        # Only store completion with original case if not sentence-initial
                        completions[prefix][token] += 1
                    else:
                        # For sentence-initial words, store lowercase version
                        completions[prefix][lower_token] += 1
            
            # Process lowercase tokens for n-grams
            lower_tokens = [t.lower() for t in tokens]
            
            # Count bigrams
            for i in range(len(lower_tokens) - 1):
                bigrams[lower_tokens[i]][lower_tokens[i+1]] += 1
            
            # Count trigrams
            for i in range(len(lower_tokens) - 2):
                key = f"{lower_tokens[i]} {lower_tokens[i+1]}"
                trigrams[key][lower_tokens[i+2]] += 1
            
            # Update sentence tracking
            sentence_start = False
            if tokens[-1][-1] in ".!?":
                sentence_start = True
            
            total_sentences += 1
            if total_sentences % 10000 == 0:
                print(f"Processed {total_sentences} sentences")
    
    print(f"Finished processing {total_sentences} sentences")
    print(f"Found {len(unigrams)} unique words")
    print(f"Found {len(completions)} unique prefixes")
    print(f"Found {len(cap_patterns)} capitalization patterns")
    
    # Save raw count models
    print("Saving models...")
    
    with open(os.path.join(output_dir, 'unigrams.json'), 'w', encoding='utf-8') as f:
        json.dump(dict(unigrams), f, ensure_ascii=False)
    
    bigram_dict = {k: dict(v) for k, v in bigrams.items()}
    with open(os.path.join(output_dir, 'bigrams.json'), 'w', encoding='utf-8') as f:
        json.dump(bigram_dict, f, ensure_ascii=False)
    
    trigram_dict = {k: dict(v) for k, v in trigrams.items()}
    with open(os.path.join(output_dir, 'trigrams.json'), 'w', encoding='utf-8') as f:
        json.dump(trigram_dict, f, ensure_ascii=False)
    
    completion_dict = {k: dict(v) for k, v in completions.items()}
    with open(os.path.join(output_dir, 'completions.json'), 'w', encoding='utf-8') as f:
        json.dump(completion_dict, f, ensure_ascii=False)
    
    cap_patterns_dict = {k: dict(v) for k, v in cap_patterns.items()}
    with open(os.path.join(output_dir, 'cap_patterns.json'), 'w', encoding='utf-8') as f:
        json.dump(cap_patterns_dict, f, ensure_ascii=False)
    
    print("Processing complete. Files saved to:", output_dir)
    return unigrams, bigrams, trigrams, completions, cap_patterns

def convert_to_probabilities(output_dir):
    """Convert raw counts to probability distributions"""
    print("Converting counts to probabilities...")
    
    # Load models
    with open(os.path.join(output_dir, 'unigrams.json'), 'r', encoding='utf-8') as f:
        unigrams = json.load(f)
    
    with open(os.path.join(output_dir, 'bigrams.json'), 'r', encoding='utf-8') as f:
        bigrams = json.load(f)
    
    with open(os.path.join(output_dir, 'trigrams.json'), 'r', encoding='utf-8') as f:
        trigrams = json.load(f)
    
    with open(os.path.join(output_dir, 'completions.json'), 'r', encoding='utf-8') as f:
        completions = json.load(f)
    
    with open(os.path.join(output_dir, 'cap_patterns.json'), 'r', encoding='utf-8') as f:
        cap_patterns = json.load(f)
    
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
    
    # Save probability models
    print("Saving probability models...")
    
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
    
    print("Probability conversion complete")

if __name__ == "__main__":
    corpus_file = "sentences.txt" 
    output_directory = "models"
    preprocess_corpus(corpus_file, output_directory)
    convert_to_probabilities(output_directory)