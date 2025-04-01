import SwiftUI

struct AssessmentView: View {
    @EnvironmentObject private var assessmentViewModel: AssessmentViewModel
    @State private var showAssessmentTypePicker = false
    @State private var showingResult = false
    @State private var selectedResult: AssessmentResult?
    
    var body: some View {
        NavigationView {
            VStack {
                if assessmentViewModel.isCompleted {
                    // Show results
                    AssessmentResultView(
                        result: assessmentViewModel.assessmentResults.first!,
                        onClose: {
                            assessmentViewModel.isCompleted = false
                        }
                    )
                } else if assessmentViewModel.currentQuestionIndex < assessmentViewModel.questions.count && !assessmentViewModel.questions.isEmpty {
                    // Show assessment in progress
                    QuestionnaireView()
                } else {
                    // Show assessment options and history
                    ScrollView {
                        VStack(spacing: 20) {
                            // Assessment options
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Screening Tools")
                                    .font(.headline)
                                
                                ForEach(QuestionnaireType.allCases, id: \.self) { type in
                                    Button(action: {
                                        assessmentViewModel.startAssessment(type: type)
                                    }) {
                                        HStack {
                                            VStack(alignment: .leading, spacing: 5) {
                                                Text(type.rawValue)
                                                    .font(.headline)
                                                    .foregroundColor(.primary)
                                                
                                                Text(type.description)
                                                    .font(.subheadline)
                                                    .foregroundColor(.secondary)
                                                    .lineLimit(2)
                                            }
                                            
                                            Spacer()
                                            
                                            Image(systemName: "chevron.right")
                                                .foregroundColor(.gray)
                                        }
                                        .padding()
                                        .background(Color(.systemGray6))
                                        .cornerRadius(12)
                                    }
                                }
                            }
                            .padding(.horizontal)
                            
                            Divider()
                                .padding(.vertical)
                            
                            // Assessment history
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Assessment History")
                                    .font(.headline)
                                    .padding(.horizontal)
                                
                                if assessmentViewModel.isLoading {
                                    ProgressView()
                                        .padding()
                                } else if assessmentViewModel.assessmentResults.isEmpty {
                                    Text("No assessment history available")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .padding()
                                } else {
                                    // List of past assessments
                                    ForEach(assessmentViewModel.assessmentResults) { result in
                                        Button(action: {
                                            selectedResult = result
                                            showingResult = true
                                        }) {
                                            HStack {
                                                VStack(alignment: .leading, spacing: 5) {
                                                    HStack {
                                                        Circle()
                                                            .fill(Color(result.severityColor))
                                                            .frame(width: 12, height: 12)
                                                        
                                                        Text(result.type == QuestionnaireType.epds.rawValue ? "EPDS" : "PHQ-9")
                                                            .font(.headline)
                                                    }
                                                    
                                                    Text("Score: \(result.score) - \(result.interpretation)")
                                                        .font(.subheadline)
                                                        .foregroundColor(.secondary)
                                                        .lineLimit(1)
                                                }
                                                
                                                Spacer()
                                                
                                                VStack(alignment: .trailing) {
                                                    Text(formatDate(result.date))
                                                        .font(.caption)
                                                        .foregroundColor(.secondary)
                                                    
                                                    Image(systemName: "chevron.right")
                                                        .foregroundColor(.gray)
                                                        .padding(.top, 5)
                                                }
                                            }
                                            .padding()
                                            .background(Color(.systemGray6))
                                            .cornerRadius(12)
                                        }
                                        .padding(.horizontal)
                                    }
                                }
                            }
                        }
                        .padding(.vertical)
                    }
                }
            }
            .navigationTitle("Assessments")
            .onAppear {
                if assessmentViewModel.assessmentResults.isEmpty {
                    assessmentViewModel.loadPreviousAssessments()
                }
            }
            .sheet(isPresented: $showingResult) {
                if let result = selectedResult {
                    AssessmentResultView(
                        result: result,
                        onClose: {
                            showingResult = false
                        }
                    )
                }
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: date)
    }
}

struct AssessmentResultView: View {
    let result: AssessmentResult
    let onClose: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 10) {
                    Image(systemName: "clipboard.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 60, height: 60)
                        .foregroundColor(Color(result.severityColor))
                    
                    Text(result.type == QuestionnaireType.epds.rawValue ? "Edinburgh Postnatal Depression Scale" : "Patient Health Questionnaire-9")
                        .font(.headline)
                    
                    Text(formatDate(result.date))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
                
                // Score
                VStack(spacing: 5) {
                    Text("Your Score")
                        .font(.headline)
                    
                    Text("\(result.score)")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(Color(result.severityColor))
                    
                    Text(result.interpretation)
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
                
                // Recommendations
                VStack(alignment: .leading, spacing: 10) {
                    Text("Recommendations")
                        .font(.headline)
                    
                    ForEach(getRecommendations(), id: \.self) { recommendation in
                        HStack(alignment: .top) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(Color("AccentColor"))
                                .padding(.top, 2)
                            
                            Text(recommendation)
                                .font(.subheadline)
                        }
                        .padding(.vertical, 5)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
                
                // Disclaimer
                Text("Note: This assessment is a screening tool and not a diagnosis. If you are concerned about your mental health, please consult with a healthcare professional.")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
                
                Button(action: onClose) {
                    Text("Close")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color("AccentColor"))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .padding(.horizontal)
                }
                
                Spacer()
            }
            .padding(.vertical)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        return formatter.string(from: date)
    }
    
    private func getRecommendations() -> [String] {
        if result.type == QuestionnaireType.epds.rawValue {
            switch result.score {
            case 0...8:
                return [
                    "Continue self-care activities",
                    "Maintain social connections",
                    "Consider retaking the assessment in 2-4 weeks"
                ]
            case 9...12:
                return [
                    "Share your feelings with a trusted person",
                    "Consider talking to your healthcare provider",
                    "Practice self-care activities daily",
                    "Retake the assessment in 1-2 weeks"
                ]
            default:
                return [
                    "Contact your healthcare provider to discuss your results",
                    "Reach out to a mental health professional",
                    "Consider calling a support hotline if needed",
                    "Do not delay seeking professional help"
                ]
            }
        } else {
            switch result.score {
            case 0...4:
                return [
                    "Continue monitoring your mood",
                    "Maintain healthy lifestyle habits",
                    "Consider retaking the assessment in 2-4 weeks"
                ]
            case 5...9:
                return [
                    "Implement regular self-care practices",
                    "Consider discussing your feelings with your doctor",
                    "Monitor for changes in symptoms",
                    "Retake the assessment in 1-2 weeks"
                ]
            case 10...14:
                return [
                    "Contact your healthcare provider to discuss your results",
                    "Consider a mental health evaluation",
                    "Establish regular self-care routines",
                    "Seek support from trusted friends or family"
                ]
            default:
                return [
                    "Contact your healthcare provider as soon as possible",
                    "Reach out to a mental health professional",
                    "Consider calling a support hotline if needed",
                    "Do not delay seeking professional help"
                ]
            }
        }
    }
}