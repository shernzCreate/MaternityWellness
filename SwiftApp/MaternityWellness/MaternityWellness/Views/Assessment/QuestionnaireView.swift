import SwiftUI

struct QuestionnaireView: View {
    @EnvironmentObject private var assessmentViewModel: AssessmentViewModel
    @State private var selectedOption: Int? = nil
    
    var currentQuestion: AssessmentQuestion {
        assessmentViewModel.getCurrentQuestion()
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Progress indicator
            ProgressView(value: Double(assessmentViewModel.currentQuestionIndex + 1), total: Double(assessmentViewModel.questions.count))
                .padding(.horizontal)
            
            HStack {
                Text("Question \(assessmentViewModel.currentQuestionIndex + 1) of \(assessmentViewModel.questions.count)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(Int(Double(assessmentViewModel.currentQuestionIndex + 1) / Double(assessmentViewModel.questions.count) * 100))%")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Question text
                    Text(currentQuestion.text)
                        .font(.headline)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    
                    // Options
                    ForEach(0..<currentQuestion.options.count, id: \.self) { index in
                        Button(action: {
                            selectedOption = index
                        }) {
                            HStack {
                                Text(currentQuestion.options[index].text)
                                    .font(.body)
                                    .multilineTextAlignment(.leading)
                                
                                Spacer()
                                
                                if selectedOption == index {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(Color("AccentColor"))
                                } else {
                                    Circle()
                                        .stroke(Color.gray, lineWidth: 1)
                                        .frame(width: 20, height: 20)
                                }
                            }
                            .padding()
                            .background(selectedOption == index ? Color("AccentColor").opacity(0.1) : Color(.systemGray6))
                            .cornerRadius(8)
                        }
                    }
                    
                    // Navigation help text
                    if assessmentViewModel.questionnaire == .epds {
                        Text("For the Edinburgh Postnatal Depression Scale, please select the option that best describes how you have felt in the past 7 days.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.top)
                    } else if assessmentViewModel.questionnaire == .phq9 {
                        Text("For the PHQ-9, please select the option that best describes how often you have been bothered by each problem over the last 2 weeks.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.top)
                    }
                }
                .padding()
            }
            
            // Navigation buttons
            HStack {
                // Back button
                Button(action: {
                    // Go to previous question
                    let previousIndex = assessmentViewModel.currentQuestionIndex - 1
                    if previousIndex >= 0 {
                        assessmentViewModel.currentQuestionIndex = previousIndex
                        selectedOption = assessmentViewModel.selectedAnswers[previousIndex]
                    }
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Previous")
                    }
                    .padding()
                    .foregroundColor(assessmentViewModel.currentQuestionIndex > 0 ? Color("AccentColor") : .gray)
                }
                .disabled(assessmentViewModel.currentQuestionIndex <= 0)
                
                Spacer()
                
                // Continue/Submit button
                Button(action: {
                    if let selectedOption = selectedOption {
                        assessmentViewModel.answerQuestion(at: assessmentViewModel.currentQuestionIndex, with: selectedOption)
                        
                        if assessmentViewModel.currentQuestionIndex < assessmentViewModel.questions.count - 1 {
                            // Move to next question
                            assessmentViewModel.currentQuestionIndex += 1
                            // Check if there's a selection for this question
                            self.selectedOption = assessmentViewModel.selectedAnswers[assessmentViewModel.currentQuestionIndex]
                        } else {
                            // End of questionnaire
                            assessmentViewModel.completeAssessment()
                        }
                    }
                }) {
                    HStack {
                        Text(assessmentViewModel.currentQuestionIndex < assessmentViewModel.questions.count - 1 ? "Next" : "Submit")
                        
                        if assessmentViewModel.currentQuestionIndex < assessmentViewModel.questions.count - 1 {
                            Image(systemName: "chevron.right")
                        }
                    }
                    .padding()
                    .background(selectedOption != nil ? Color("AccentColor") : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .disabled(selectedOption == nil)
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .navigationTitle(assessmentViewModel.questionnaire == .epds ? "EPDS Assessment" : "PHQ-9 Assessment")
        .navigationBarItems(
            trailing: Button(action: {
                // Cancel assessment
                assessmentViewModel.cancelAssessment()
            }) {
                Text("Cancel")
            }
        )
        .onAppear {
            // Check if there's already a selected answer for the current question
            selectedOption = assessmentViewModel.selectedAnswers[assessmentViewModel.currentQuestionIndex]
        }
    }
}