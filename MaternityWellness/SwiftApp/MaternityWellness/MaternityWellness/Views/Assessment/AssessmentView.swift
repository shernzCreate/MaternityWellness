import SwiftUI

struct AssessmentView: View {
    @State private var showQuestionnaireSheet = false
    @State private var selectedQuestionnaire: AssessmentType = .epds
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Introduction section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Mental Health Check")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Regular screening can help identify early signs of postpartum depression and anxiety.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    
                    // Questionnaire options
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Choose an assessment")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        // EPDS Card
                        assessmentCard(
                            title: AssessmentType.epds.abbreviation,
                            fullName: AssessmentType.epds.rawValue,
                            description: AssessmentType.epds.description,
                            questionCount: 10,
                            timeEstimate: "3-5",
                            action: {
                                selectedQuestionnaire = .epds
                                showQuestionnaireSheet = true
                            }
                        )
                        
                        // PHQ-9 Card
                        assessmentCard(
                            title: AssessmentType.phq9.abbreviation,
                            fullName: AssessmentType.phq9.rawValue,
                            description: AssessmentType.phq9.description,
                            questionCount: 9,
                            timeEstimate: "2-4",
                            action: {
                                selectedQuestionnaire = .phq9
                                showQuestionnaireSheet = true
                            }
                        )
                    }
                    
                    // Assessment history
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Assessment History")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        // If there are no assessments
                        VStack {
                            Text("No assessment history yet")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Text("Complete an assessment to see your results here")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .padding(.horizontal)
                        
                        // Notes on privacy
                        Text("Note: All assessment data is stored locally on your device. Your privacy is important to us.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                            .padding(.top, 16)
                    }
                    .padding(.top, 20)
                    
                    // Singapore resources disclaimer
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Important")
                            .font(.headline)
                        
                        Text("These assessments are screening tools only and do not constitute a diagnosis. If you're experiencing distress, please contact a healthcare provider.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("Singapore National Care Hotline: 1800-202-6868")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                }
            }
            .navigationBarTitle("Assessment", displayMode: .inline)
            .sheet(isPresented: $showQuestionnaireSheet) {
                if selectedQuestionnaire == .epds {
                    QuestionnaireView(
                        title: "Edinburgh Postnatal Depression Scale",
                        description: "Please select the answer that comes closest to how you have felt in the past 7 days, not just how you feel today.",
                        questions: epdsQuestions,
                        questionnaire: .epds
                    )
                } else {
                    QuestionnaireView(
                        title: "Patient Health Questionnaire-9",
                        description: "Over the last 2 weeks, how often have you been bothered by any of the following problems?",
                        questions: phq9Questions,
                        questionnaire: .phq9
                    )
                }
            }
        }
    }
    
    private func assessmentCard(title: String, fullName: String, description: String, questionCount: Int, timeEstimate: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(title)
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
                
                Text(fullName)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(description)
                    .font(.body)
                    .foregroundColor(.primary)
                    .padding(.top, 4)
                
                HStack(spacing: 16) {
                    Label("\(questionCount) questions", systemImage: "list.bullet")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Label("\(timeEstimate) minutes", systemImage: "clock")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 8)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            .padding(.horizontal)
        }
        .buttonStyle(PlainButtonStyle())
    }
}