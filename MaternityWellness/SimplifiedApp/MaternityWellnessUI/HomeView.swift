import SwiftUI

struct HomeView: View {
    @State private var currentMood: String = "neutral"
    @State private var showMoodTracker = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Welcome Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Welcome Back")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("How are you feeling today?")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding()
                    
                    // Mood Tracker Card
                    VStack {
                        HStack {
                            Text("Today's Mood")
                                .font(.headline)
                            Spacer()
                            Button("Update") {
                                showMoodTracker = true
                            }
                            .font(.subheadline)
                            .foregroundColor(.blue)
                        }
                        .padding(.horizontal)
                        
                        HStack(spacing: 25) {
                            moodIcon(name: "😊", isSelected: currentMood == "happy")
                            moodIcon(name: "😐", isSelected: currentMood == "neutral")
                            moodIcon(name: "😔", isSelected: currentMood == "sad")
                            moodIcon(name: "😢", isSelected: currentMood == "depressed")
                            moodIcon(name: "😡", isSelected: currentMood == "angry")
                        }
                        .padding()
                    }
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    // Quick Assessment
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Quick Assessment")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        NavigationLink(destination: AssessmentView()) {
                            HStack {
                                Image(systemName: "clipboard.fill")
                                    .foregroundColor(.blue)
                                
                                VStack(alignment: .leading) {
                                    Text("EPDS Questionnaire")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                    
                                    Text("Edinburgh Postnatal Depression Scale")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            .padding(.horizontal)
                        }
                        
                        NavigationLink(destination: AssessmentView()) {
                            HStack {
                                Image(systemName: "clipboard.fill")
                                    .foregroundColor(.blue)
                                
                                VStack(alignment: .leading) {
                                    Text("PHQ-9 Questionnaire")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                    
                                    Text("Patient Health Questionnaire")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            .padding(.horizontal)
                        }
                    }
                    
                    // Featured Resources
                    VStack(alignment: .leading, spacing: 15) {
                        HStack {
                            Text("Featured Resources")
                                .font(.headline)
                            
                            Spacer()
                            
                            NavigationLink(destination: ResourcesView()) {
                                Text("See All")
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                resourceCard(
                                    title: "Coping with PPD",
                                    description: "Strategies from KK Hospital experts",
                                    imageName: "heart.fill"
                                )
                                
                                resourceCard(
                                    title: "Self-Care Tips",
                                    description: "Essential self-care for new mothers",
                                    imageName: "plus.circle.fill"
                                )
                                
                                resourceCard(
                                    title: "Support Networks",
                                    description: "Singapore community resources",
                                    imageName: "person.3.fill"
                                )
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Home")
            .sheet(isPresented: $showMoodTracker) {
                MoodTrackerView(selectedMood: $currentMood)
            }
        }
    }
    
    private func moodIcon(name: String, isSelected: Bool) -> some View {
        Text(name)
            .font(.system(size: 30))
            .padding(10)
            .background(isSelected ? Color.blue.opacity(0.2) : Color.clear)
            .cornerRadius(10)
    }
    
    private func resourceCard(title: String, description: String, imageName: String) -> some View {
        VStack(alignment: .leading) {
            Image(systemName: imageName)
                .font(.largeTitle)
                .foregroundColor(.blue)
                .padding(.bottom, 5)
            
            Text(title)
                .font(.headline)
            
            Text(description)
                .font(.caption)
                .foregroundColor(.gray)
                .lineLimit(2)
        }
        .padding()
        .frame(width: 160, height: 160)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
