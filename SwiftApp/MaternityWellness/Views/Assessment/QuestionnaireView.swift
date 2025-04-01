import SwiftUI

struct QuestionnaireView: View {
    let type: AssessmentType
    @ObservedObject var viewModel: AssessmentViewModel
    @Binding var isPresented: Bool
    
    @State private var currentQuestionIndex = 0
    @State private var answers: [Int: Int] = [:]
    @State private var isComplete = false
    @State private var result: AssessmentResult?
    
    private var questions: [AssessmentQuestion] {
        switch type {
        case .epds:
            return viewModel.epdsQuestions
        case .phq9:
            return viewModel.phq9Questions
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if isComplete {
                    resultView
                } else {
                    questionView
                }
            }
            .navigationTitle(type.rawValue)
            .navigationBarItems(
                leading: Button("Cancel") {
                    isPresented = false
                },
                trailing: isComplete ? nil : Text("\(currentQuestionIndex + 1)/\(questions.count)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            )
        }
    }
    
    private var questionView: some View {
        VStack(spacing: 30) {
            // Progress indicator
            ProgressView(value: Double(currentQuestionIndex + 1), total: Double(questions.count))
                .padding(.horizontal)
                .padding(.top)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Question
                    Text(questions[currentQuestionIndex].question)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    // Options
                    VStack(spacing: 12) {
                        ForEach(questions[currentQuestionIndex].options, id: \.value) { option in
                            optionButton(option: option)
                        }
                    }
                }
                .padding()
            }
            
            // Navigation buttons
            HStack(spacing: 20) {
                if currentQuestionIndex > 0 {
                    Button(action: {
                        currentQuestionIndex -= 1
                    }) {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Previous")
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.gray.opacity(0.1))
                        .foregroundColor(.primary)
                        .cornerRadius(12)
                    }
                } else {
                    // Empty spacer when there's no previous button
                    Spacer()
                }
                
                if let answer = answers[questions[currentQuestionIndex].id], currentQuestionIndex < questions.count - 1 {
                    Button(action: {
                        currentQuestionIndex += 1
                    }) {
                        HStack {
                            Text("Next")
                            Image(systemName: "chevron.right")
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color("AccentColor"))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                } else if let answer = answers[questions[currentQuestionIndex].id], currentQuestionIndex == questions.count - 1 {
                    Button(action: completeQuestionnaire) {
                        Text("Submit")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color("AccentColor"))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                } else {
                    // Empty spacer when there's no next/submit button
                    Spacer()
                }
            }
            .padding()
        }
    }
    
    private var resultView: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Score overview
                VStack(spacing: 16) {
                    Text("Assessment Complete")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    if let result = result {
                        // Score circle
                        ZStack {
                            Circle()
                                .stroke(Color.gray.opacity(0.2), lineWidth: 15)
                                .frame(width: 160, height: 160)
                            
                            Circle()
                                .trim(from: 0, to: getScorePercentage())
                                .stroke(Color(result.interpretation.color), lineWidth: 15)
                                .frame(width: 160, height: 160)
                                .rotationEffect(.degrees(-90))
                            
                            VStack(spacing: 4) {
                                Text("\(result.score)")
                                    .font(.system(size: 36, weight: .bold))
                                
                                Text("points")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical)
                        
                        // Interpretation
                        VStack(spacing: 8) {
                            Text(result.interpretation.severity)
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(Color(result.interpretation.color))
                            
                            Text(result.interpretation.description)
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(.horizontal)
                        }
                    }
                }
                
                // Recommendations
                if let result = result {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Recommendations")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            ForEach(getRecommendations(for: result), id: \.self) { recommendation in
                                HStack(alignment: .top, spacing: 12) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(Color("AccentColor"))
                                        .font(.subheadline)
                                        .padding(.top, 2)
                                    
                                    Text(recommendation)
                                        .font(.subheadline)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                        .padding(.horizontal)
                    }
                }
                
                Spacer(minLength: 20)
                
                // Action buttons
                VStack(spacing: 16) {
                    Button(action: {
                        isPresented = false
                    }) {
                        Text("Done")
                            .fontWeight(.semibold)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color("AccentColor"))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    
                    // Add a button to view care plan if score indicates concern
                    if let result = result, result.interpretation.severity != "Minimal" && result.interpretation.severity != "Low" {
                        NavigationLink(destination: Text("Care Plan View")) {
                            Text("View Support Resources")
                                .fontWeight(.semibold)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.white)
                                .foregroundColor(Color("AccentColor"))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color("AccentColor"), lineWidth: 2)
                                )
                                .cornerRadius(12)
                        }
                    }
                }
                .padding()
            }
        }
    }
    
    private func optionButton(option: AssessmentOption) -> some View {
        Button(action: {
            answers[questions[currentQuestionIndex].id] = option.value
        }) {
            HStack {
                Text(option.label)
                    .font(.body)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                
                Spacer()
                
                if answers[questions[currentQuestionIndex].id] == option.value {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color("AccentColor"))
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(answers[questions[currentQuestionIndex].id] == option.value ? Color("AccentColor") : Color.gray.opacity(0.3), lineWidth: 2)
                    .background(
                        answers[questions[currentQuestionIndex].id] == option.value ? Color("AccentColor").opacity(0.1) : Color.white
                    )
            )
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func completeQuestionnaire() {
        guard answers.count == questions.count else { return }
        
        // Calculate total score
        let score = answers.values.reduce(0, +)
        
        // Create assessment result
        result = viewModel.saveAssessment(type: type, score: score, answers: answers)
        
        // Update UI
        isComplete = true
    }
    
    private func getScorePercentage() -> CGFloat {
        guard let result = result else { return 0 }
        
        let maxScore: CGFloat = type == .epds ? 30.0 : 27.0
        return CGFloat(result.score) / maxScore
    }
    
    private func getRecommendations(for result: AssessmentResult) -> [String] {
        var recommendations: [String] = []
        
        // General recommendations for everyone
        recommendations.append("Continue to monitor your mood and emotional health regularly.")
        recommendations.append("Maintain healthy sleep, nutrition, and exercise habits.")
        
        // Conditional recommendations based on score
        switch type {
        case .epds:
            if result.score >= 9 && result.score <= 12 {
                recommendations.append("Consider discussing your feelings with a healthcare provider.")
                recommendations.append("Use the resources in this app to learn more about managing postpartum emotions.")
            } else if result.score >= 13 {
                recommendations.append("We recommend speaking with a healthcare professional soon about your symptoms.")
                recommendations.append("Explore the support resources section of this app for local mental health services in Singapore.")
                recommendations.append("Share your feelings with someone you trust - you don't have to face this alone.")
            }
            
            // Check if question 10 (self-harm) has a non-zero response
            if let q10Response = answers[10], q10Response > 0 {
                recommendations.append("Your response indicates thoughts of self-harm. Please contact a healthcare provider or mental health helpline immediately.")
                recommendations.insert("National Care Hotline: 1800-202-6868", at: 0)
                recommendations.insert("Institute of Mental Health's Mental Health Helpline: 6389-2222", at: 0)
            }
            
        case .phq9:
            if result.score >= 5 && result.score <= 9 {
                recommendations.append("Practice stress-reduction techniques like deep breathing and mindfulness.")
                recommendations.append("Seek social support from friends and family.")
            } else if result.score >= 10 && result.score <= 14 {
                recommendations.append("We recommend consulting with a healthcare provider about your symptoms.")
                recommendations.append("Regular physical activity can help improve mild to moderate depression symptoms.")
            } else if result.score >= 15 {
                recommendations.append("We strongly recommend speaking with a healthcare professional soon.")
                recommendations.append("Explore the support resources section for mental health services in Singapore.")
            }
            
            // Check if question 9 (self-harm) has a non-zero response
            if let q9Response = answers[9], q9Response > 0 {
                recommendations.append("Your response indicates thoughts of self-harm. Please contact a healthcare provider or mental health helpline immediately.")
                recommendations.insert("National Care Hotline: 1800-202-6868", at: 0)
                recommendations.insert("Institute of Mental Health's Mental Health Helpline: 6389-2222", at: 0)
            }
        }
        
        return recommendations
    }
}

struct QuestionnaireView_Previews: PreviewProvider {
    static var previews: some View {
        QuestionnaireView(
            type: .epds,
            viewModel: AssessmentViewModel(userId: "preview_user"),
            isPresented: .constant(true)
        )
    }
}