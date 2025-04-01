import SwiftUI

struct AssessmentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = AssessmentViewModel(userId: "placeholder")
    @State private var selectedType: AssessmentType = .epds
    @State private var showingQuestionnaire = false
    @State private var showingHistory = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Header with title and description
            VStack(alignment: .leading, spacing: 8) {
                Text("Mental Health Assessment")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Regular check-ins can help track your emotional wellbeing and provide insights for better care.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            
            // Assessment type selector
            Picker("Assessment Type", selection: $selectedType) {
                ForEach(AssessmentType.allCases, id: \.self) { type in
                    Text(type.rawValue).tag(type)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            
            // Assessment information card
            VStack(alignment: .leading, spacing: 16) {
                // Icon and title
                HStack(spacing: 8) {
                    Image(systemName: selectedType == .epds ? "heart.text.square.fill" : "checklist")
                        .font(.title2)
                        .foregroundColor(Color("AccentColor"))
                    
                    Text(selectedType == .epds ? "Edinburgh Postnatal Depression Scale" : "Patient Health Questionnaire-9")
                        .font(.headline)
                }
                
                // Description
                Text(selectedType == .epds ? 
                     "A 10-question screening tool to help identify mothers at risk for perinatal depression. This questionnaire focuses on how you've been feeling in the past 7 days." : 
                     "A 9-question assessment used to screen for depression severity. It evaluates how frequently you've experienced certain problems in the past 2 weeks.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                
                // Time required
                HStack {
                    Image(systemName: "clock")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("Takes approximately 3-5 minutes")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                // Last assessment info if available
                if let lastAssessment = viewModel.getLastAssessmentByType(type: selectedType) {
                    Divider()
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Last completed:")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Text(formatDate(lastAssessment.date))
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("Your score:")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Text("\(lastAssessment.score)")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(Color(lastAssessment.interpretation.color))
                        }
                    }
                }
                
                // Start assessment button
                Button(action: {
                    showingQuestionnaire = true
                }) {
                    Text("Start Assessment")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color("AccentColor"))
                        .cornerRadius(12)
                }
                .padding(.top, 8)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            .padding(.horizontal)
            
            // Assessment history and trends
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("Assessment History")
                        .font(.headline)
                    
                    Spacer()
                    
                    Button(action: {
                        showingHistory = true
                    }) {
                        Text("View All")
                            .font(.subheadline)
                            .foregroundColor(Color("AccentColor"))
                    }
                }
                
                if viewModel.assessments.isEmpty {
                    Text("Complete your first assessment to start tracking your mental health over time.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 20)
                } else {
                    // Simple trend visualization
                    if viewModel.assessments.count > 1 {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Your Progress")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            // Simple bar chart representation of scores
                            HStack(alignment: .bottom, spacing: 4) {
                                ForEach(viewModel.getLastAssessments(limit: 5).reversed(), id: \.id) { assessment in
                                    VStack(spacing: 4) {
                                        // Score value
                                        Text("\(assessment.score)")
                                            .font(.caption2)
                                            .foregroundColor(.white)
                                            .padding(.vertical, 2)
                                            .padding(.horizontal, 4)
                                            .background(Color(assessment.interpretation.color))
                                            .cornerRadius(4)
                                        
                                        // Bar
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(Color(assessment.interpretation.color))
                                            .frame(width: 20, height: getBarHeight(score: assessment.score, type: assessment.type))
                                        
                                        // Date
                                        Text(formatShortDate(assessment.date))
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                    }
                                    .frame(maxWidth: .infinity)
                                }
                            }
                            .frame(height: 100)
                            .padding(.vertical, 8)
                        }
                    }
                    
                    // Most recent assessment result
                    if let latest = viewModel.getLatestAssessment() {
                        Divider()
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Latest Result")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(latest.type.rawValue)
                                        .font(.headline)
                                    
                                    Text(formatDate(latest.date))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .trailing, spacing: 4) {
                                    HStack {
                                        Text(latest.interpretation.severity)
                                            .font(.subheadline)
                                            .foregroundColor(Color(latest.interpretation.color))
                                        
                                        Text("(\(latest.score))")
                                            .font(.subheadline)
                                            .fontWeight(.bold)
                                            .foregroundColor(Color(latest.interpretation.color))
                                    }
                                    
                                    Text(latest.interpretation.description)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.trailing)
                                }
                            }
                        }
                    }
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            .padding(.horizontal)
            
            Spacer()
        }
        .padding(.vertical)
        .background(Color.gray.opacity(0.05))
        .navigationTitle("Assessment")
        .onAppear {
            if let userId = authViewModel.currentUser?.id {
                if viewModel.userId != userId {
                    viewModel.userId = userId
                    viewModel.loadAssessments()
                }
            }
        }
        .sheet(isPresented: $showingQuestionnaire) {
            QuestionnaireView(
                type: selectedType,
                viewModel: viewModel,
                isPresented: $showingQuestionnaire
            )
        }
        .sheet(isPresented: $showingHistory) {
            AssessmentHistoryView(viewModel: viewModel)
        }
    }
    
    private func getBarHeight(score: Int, type: AssessmentType) -> CGFloat {
        let maxScore: CGFloat = type == .epds ? 30.0 : 27.0
        let maxHeight: CGFloat = 100.0
        
        return max(20, (CGFloat(score) / maxScore) * maxHeight)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    private func formatShortDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"
        return formatter.string(from: date)
    }
}

struct AssessmentView_Previews: PreviewProvider {
    static var previews: some View {
        let authViewModel = AuthViewModel()
        authViewModel.currentUser = User(username: "testuser", fullName: "Test User", email: "test@example.com")
        
        return NavigationView {
            AssessmentView()
                .environmentObject(authViewModel)
        }
    }
}