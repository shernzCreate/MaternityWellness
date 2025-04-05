import SwiftUI

struct QuestionnaireView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var authViewModel: AuthViewModel
    
    let title: String
    let description: String
    let questions: [AssessmentQuestion]
    let questionnaire: AssessmentType
    
    @State private var currentQuestionIndex = 0
    @State private var answers: [Int: Int] = [:]
    @State private var showResult = false
    @State private var totalScore = 0
    
    var body: some View {
        VStack {
            if showResult {
                // Show results
                assessmentResultView
            } else {
                // Questionnaire
                questionnaireFormView
            }
        }
        .background(Color(.systemBackground))
        .navigationBarTitle(title, displayMode: .inline)
    }
    
    private var questionnaireFormView: some View {
        VStack(spacing: 20) {
            // Progress indicator
            VStack(spacing: 8) {
                ProgressView(value: Double(currentQuestionIndex), total: Double(questions.count))
                    .progressViewStyle(LinearProgressViewStyle())
                    .tint(Color("AccentColor"))
                
                HStack {
                    Text("Question \(currentQuestionIndex + 1) of \(questions.count)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
            }
            .padding(.horizontal)
            
            // Description (only shown on first question)
            if currentQuestionIndex == 0 {
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                    .padding(.bottom, 10)
            }
            
            // Question
            VStack(alignment: .leading, spacing: 20) {
                let question = questions[currentQuestionIndex]
                
                Text(question.text)
                    .font(.headline)
                    .padding(.horizontal)
                
                // Options
                VStack(spacing: 10) {
                    ForEach(0..<question.options.count, id: \.self) { index in
                        Button(action: {
                            answers[question.id] = question.scores[index]
                            
                            // Move to next question or show results
                            if currentQuestionIndex < questions.count - 1 {
                                withAnimation {
                                    currentQuestionIndex += 1
                                }
                            } else {
                                calculateResult()
                            }
                        }) {
                            HStack {
                                Text(question.options[index])
                                    .foregroundColor(.primary)
                                    .multilineTextAlignment(.leading)
                                
                                Spacer()
                                
                                if answers[question.id] == question.scores[index] {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(Color("AccentColor"))
                                } else {
                                    Image(systemName: "circle")
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(answers[question.id] == question.scores[index] ? 
                                          Color("AccentColor").opacity(0.1) : Color(.systemGray6))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(answers[question.id] == question.scores[index] ? 
                                            Color("AccentColor") : Color.clear, lineWidth: 1)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal)
            }
            
            Spacer()
            
            // Navigation buttons
            HStack {
                if currentQuestionIndex > 0 {
                    Button(action: {
                        withAnimation {
                            currentQuestionIndex -= 1
                        }
                    }) {
                        Text("Previous")
                            .fontWeight(.medium)
                            .foregroundColor(Color("AccentColor"))
                            .padding()
                            .padding(.horizontal)
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                    }
                }
                
                Spacer()
                
                // Skip button (only if current question isn't answered)
                if answers[questions[currentQuestionIndex].id] == nil {
                    Button(action: {
                        if currentQuestionIndex < questions.count - 1 {
                            withAnimation {
                                currentQuestionIndex += 1
                            }
                        } else {
                            calculateResult()
                        }
                    }) {
                        Text("Skip")
                            .fontWeight(.medium)
                            .foregroundColor(.gray)
                            .padding()
                            .padding(.horizontal)
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 30)
        }
    }
    
    private var assessmentResultView: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Result header
                VStack(spacing: 10) {
                    Text(getResultTitle())
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Your score: \(totalScore)")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                .padding()
                
                // Visualization
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 20)
                        .frame(width: 200, height: 200)
                    
                    Circle()
                        .trim(from: 0, to: CGFloat(min(Double(totalScore) / getMaxScore(), 1.0)))
                        .stroke(getResultColor(), lineWidth: 20)
                        .frame(width: 200, height: 200)
                        .rotationEffect(.degrees(-90))
                    
                    VStack {
                        Text("\(totalScore)")
                            .font(.system(size: 50, weight: .bold))
                        
                        Text("of \(getMaxScore())")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                
                // Interpretation
                VStack(alignment: .leading, spacing: 16) {
                    Text("What this means")
                        .font(.headline)
                    
                    Text(getResultInterpretation())
                        .font(.body)
                    
                    if isHighRisk() {
                        Text("⚠️ Your score suggests you may be experiencing significant symptoms. Please consider speaking with a healthcare provider.")
                            .font(.callout)
                            .foregroundColor(.red)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 12).fill(Color.red.opacity(0.1)))
                    }
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemGray6)))
                .padding(.horizontal)
                
                // Singapore-specific resources
                VStack(alignment: .leading, spacing: 16) {
                    Text("Singapore Resources")
                        .font(.headline)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        resourceLink(
                            title: "KK Hospital Women's Mental Wellness Service",
                            phone: "6394 1000"
                        )
                        
                        resourceLink(
                            title: "National Care Hotline",
                            phone: "1800 202 6868"
                        )
                        
                        resourceLink(
                            title: "Singapore Association for Mental Health",
                            phone: "1800 283 7019"
                        )
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemBackground)))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
                }
                .padding(.horizontal)
                
                // Buttons
                VStack(spacing: 16) {
                    Button(action: {
                        // Save result to user history
                        saveResult()
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Save and Close")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color("AccentColor"))
                            .cornerRadius(10)
                    }
                    
                    Button(action: {
                        // Restart assessment
                        withAnimation {
                            resetQuestionnaire()
                        }
                    }) {
                        Text("Retake Assessment")
                            .fontWeight(.medium)
                            .foregroundColor(Color("AccentColor"))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                    }
                }
                .padding()
            }
        }
    }
    
    private func resourceLink(title: String, phone: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
            
            Button(action: {
                // Call the number
                if let url = URL(string: "tel://\(phone.replacingOccurrences(of: " ", with: ""))") {
                    UIApplication.shared.open(url)
                }
            }) {
                Label(phone, systemImage: "phone.fill")
                    .font(.caption)
                    .foregroundColor(Color("AccentColor"))
            }
        }
    }
    
    private func calculateResult() {
        // Calculate total score
        totalScore = answers.values.reduce(0, +)
        showResult = true
    }
    
    private func saveResult() {
        // In a real app, this would save to a database or user defaults
        // For demo purposes, we're just simulating this
        print("Saved \(questionnaire.abbreviation) result: \(totalScore)")
    }
    
    private func resetQuestionnaire() {
        currentQuestionIndex = 0
        answers = [:]
        showResult = false
        totalScore = 0
    }
    
    private func getMaxScore() -> Int {
        return questionnaire == .epds ? 30 : 27
    }
    
    private func getResultTitle() -> String {
        switch questionnaire {
        case .epds:
            if totalScore >= 0 && totalScore <= 8 {
                return "Low Likelihood of Depression"
            } else if totalScore >= 9 && totalScore <= 12 {
                return "Possible Depression"
            } else {
                return "Probable Depression"
            }
        case .phq9:
            if totalScore >= 0 && totalScore <= 4 {
                return "Minimal Depression"
            } else if totalScore >= 5 && totalScore <= 9 {
                return "Mild Depression"
            } else if totalScore >= 10 && totalScore <= 14 {
                return "Moderate Depression"
            } else if totalScore >= 15 && totalScore <= 19 {
                return "Moderately Severe Depression"
            } else {
                return "Severe Depression"
            }
        }
    }
    
    private func getResultInterpretation() -> String {
        switch questionnaire {
        case .epds:
            if totalScore >= 0 && totalScore <= 8 {
                return "Your score suggests you are likely not experiencing significant symptoms of postpartum depression. Continue to monitor your mood and reach out for support if needed."
            } else if totalScore >= 9 && totalScore <= 12 {
                return "Your score suggests you may be experiencing some symptoms of postpartum depression. Consider talking with a healthcare provider about your feelings."
            } else {
                return "Your score suggests you may be experiencing significant symptoms of postpartum depression. It is recommended that you speak with a healthcare provider as soon as possible."
            }
        case .phq9:
            if totalScore >= 0 && totalScore <= 4 {
                return "Your score suggests minimal depression symptoms. Continue to monitor your mood and practice self-care."
            } else if totalScore >= 5 && totalScore <= 9 {
                return "Your score suggests mild depression. Consider watchful waiting, and repeat this assessment in two weeks."
            } else if totalScore >= 10 && totalScore <= 14 {
                return "Your score suggests moderate depression. Consider speaking with a healthcare provider about treatment options."
            } else if totalScore >= 15 && totalScore <= 19 {
                return "Your score suggests moderately severe depression. Active treatment with medication and/or therapy is recommended."
            } else {
                return "Your score suggests severe depression. Immediate treatment with medication and therapy is strongly recommended."
            }
        }
    }
    
    private func getResultColor() -> Color {
        switch questionnaire {
        case .epds:
            if totalScore >= 0 && totalScore <= 8 {
                return Color("GoodMood")
            } else if totalScore >= 9 && totalScore <= 12 {
                return Color("OkayMood")
            } else {
                return Color("TerribleMood")
            }
        case .phq9:
            if totalScore >= 0 && totalScore <= 4 {
                return Color("GreatMood")
            } else if totalScore >= 5 && totalScore <= 9 {
                return Color("GoodMood")
            } else if totalScore >= 10 && totalScore <= 14 {
                return Color("OkayMood")
            } else if totalScore >= 15 && totalScore <= 19 {
                return Color("SadMood")
            } else {
                return Color("TerribleMood")
            }
        }
    }
    
    private func isHighRisk() -> Bool {
        // Check for high risk responses, particularly for self-harm questions
        if questionnaire == .epds && (answers[10] ?? 0) > 0 {
            return true // EPDS question 10 is about self-harm
        }
        
        if questionnaire == .phq9 && (answers[9] ?? 0) > 0 {
            return true // PHQ-9 question 9 is about self-harm
        }
        
        // Also check overall high scores
        if (questionnaire == .epds && totalScore >= 13) ||
           (questionnaire == .phq9 && totalScore >= 15) {
            return true
        }
        
        return false
    }
}