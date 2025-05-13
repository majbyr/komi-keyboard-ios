import Foundation

class PredictionEngine {
    private var unigramProbs: [String: Double] = [:]
    private var bigramProbs: [String: [String: Double]] = [:]
    private var trigramProbs: [String: [String: Double]] = [:]
    private var completionProbs: [String: [String: Double]] = [:]
    private var capPatternProbs: [String: [String: Double]] = [:]
    
    init() {
        loadModels()
    }
    
    private func loadModels() {
        let extensionBundle = Bundle(for: type(of: self))
        
        do {
            if let unigramURL = extensionBundle.url(forResource: "unigram_probs", withExtension: "json") {
                let unigramData = try Data(contentsOf: unigramURL)
                unigramProbs = try JSONDecoder().decode([String: Double].self, from: unigramData)
            }
            
            if let bigramURL = extensionBundle.url(forResource: "bigram_probs", withExtension: "json") {
                let bigramData = try Data(contentsOf: bigramURL)
                bigramProbs = try JSONDecoder().decode([String: [String: Double]].self, from: bigramData)
            }
            
            if let trigramURL = extensionBundle.url(forResource: "trigram_probs", withExtension: "json") {
                let trigramData = try Data(contentsOf: trigramURL)
                trigramProbs = try JSONDecoder().decode([String: [String: Double]].self, from: trigramData)
            }
            
            if let completionURL = extensionBundle.url(forResource: "completion_probs", withExtension: "json") {
                let completionData = try Data(contentsOf: completionURL)
                completionProbs = try JSONDecoder().decode([String: [String: Double]].self, from: completionData)
            }
            
            if let capURL = extensionBundle.url(forResource: "cap_patterns_probs", withExtension: "json") {
                let capData = try Data(contentsOf: capURL)
                capPatternProbs = try JSONDecoder().decode([String: [String: Double]].self, from: capData)
            }
        } catch {
            // Failed to load models - predictions will fall back to empty results
        }
    }
    
    func getPredictions(for context: String, maxSuggestions: Int = 3) -> [String] {
        let words = context.trimmingCharacters(in: .whitespacesAndNewlines)
            .split(separator: " ")
            .map(String.init)
        
        let lowerWords = words.map { $0.lowercased() }
        
        if !context.hasSuffix(" "), let currentWord = lowerWords.last, let originalWord = words.last {
            let startsWithUpper = originalWord.first?.isUppercase == true
            
            if let completions = completionProbs[currentWord] {
                let predictions = Array(completions.sorted { $0.value > $1.value }
                    .prefix(maxSuggestions)
                    .map { $0.key })
                
                if !predictions.isEmpty {
                    // capitalization patterns and respect input case
                    let result = predictions.map { word in
                        if let patterns = capPatternProbs[word.lowercased()],
                           let bestPattern = patterns.max(by: { $0.value < $1.value }) {
                            let pattern = bestPattern.key
                            
                            // pattern is uppercase, it's an abbreviation - keep it
                            if pattern.uppercased() == pattern && pattern.count >= 2 {
                                return pattern
                            }
                            
                            // If input starts with uppercase, capitalize the suggestion
                            if startsWithUpper {
                                return pattern.prefix(1).uppercased() + pattern.dropFirst()
                            }
                            
                            return pattern
                        }
                        // follow input capitalization
                        return startsWithUpper ? 
                            word.prefix(1).uppercased() + word.dropFirst() : 
                            word
                    }
                    return result
                }
            }
            
            let prefixMatches = unigramProbs.keys
                .filter { $0.lowercased().hasPrefix(currentWord) && $0.lowercased() != currentWord }
                .sorted { unigramProbs[$0] ?? 0 > unigramProbs[$1] ?? 0 }
                .prefix(maxSuggestions)
                .map { word -> String in
                    if let patterns = capPatternProbs[word.lowercased()],
                       let bestPattern = patterns.max(by: { $0.value < $1.value }) {
                        if bestPattern.key.uppercased() == bestPattern.key {
                            return bestPattern.key
                        } else if startsWithUpper {
                            return bestPattern.key.prefix(1).uppercased() + bestPattern.key.dropFirst()
                        } else {
                            return bestPattern.key
                        }
                    }
                    if startsWithUpper {
                        return word.prefix(1).uppercased() + word.dropFirst()
                    }
                    return word
                }
            
            if !prefixMatches.isEmpty {
                return Array(prefixMatches)
            }
        }
        
        if let lastWord = lowerWords.last {
            if lowerWords.count >= 2 {
                let previousWord = lowerWords[lowerWords.count - 2]
                let key = "\(previousWord) \(lastWord)"
                
                if let predictions = trigramProbs[key] {
                    let result = Array(predictions.sorted { $0.value > $1.value }
                        .prefix(maxSuggestions)
                        .map { pair -> String in
                            let word = pair.key
                            if let patterns = capPatternProbs[word.lowercased()],
                               let bestPattern = patterns.max(by: { $0.value < $1.value }) {
                                return bestPattern.key
                            }
                            return word
                        })
                    if !result.isEmpty {
                        return result
                    }
                }
            }
            
            if let predictions = bigramProbs[lastWord] {
                let result = Array(predictions.sorted { $0.value > $1.value }
                    .prefix(maxSuggestions)
                    .map { pair -> String in
                            let word = pair.key
                            if let patterns = capPatternProbs[word.lowercased()],
                               let bestPattern = patterns.max(by: { $0.value < $1.value }) {
                                return bestPattern.key
                            }
                            return word
                        })
                if !result.isEmpty {
                    return result
                }
            }
        }
        
        return Array(unigramProbs.sorted { $0.value > $1.value }
            .prefix(maxSuggestions)
            .map { pair -> String in
                let word = pair.key
                if let patterns = capPatternProbs[word.lowercased()],
                   let bestPattern = patterns.max(by: { $0.value < $1.value }) {
                    return bestPattern.key
                }
                return word
            })
    }
}

private extension Character {
    var isTerminalPunctuation: Bool {
        [".", "!", "?", "\n"].contains(self)
    }
}
