import SwiftUI

struct MoodTrackerView: View {
    @State private var selectedMood: String = "😊"
    @State private var notes: String = ""
    @State private var showingSuccess = false
    
    // Sample mood history
    let moodHistory = [
        MoodEntry(date: Date().addingTimeInterval(-0*24*60*60), mood: "😊", notes: "Had a good day with baby"),
        MoodEntry(date: Date().addingTimeInterval(-1*24*60*60), mood: "😐", notes: "Feeling tired but okay"),
        MoodEntry(date: Date().addingTimeInterval(-2*24*60*60), mood: "😴", notes: "Very tired today"),
        MoodEntry(date: Date().addingTimeInterval(-3*24*60*60), mood: "😢", notes: "Had a rough night"),
        MoodEntry(date: Date().addingTimeInterval(-4*24*60*60), mood: "😊", notes: "Baby slept through the night!"),
        MoodEntry(date: Date().addingTimeInterval(-5*24*60*60), mood: "😐", notes: "")
    ]
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    var body: some View {
        NavigationView {
            ZStack {
                ColorTheme.backgroundGradient
                    .edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 25) {
                        // Today's Mood Tracker
                        VStack(alignment: .leading, spacing: 15) {
                            Text("How are you feeling today?")
                                .font(.headline)
                                .foregroundColor(ColorTheme.textGray)
                            
                            HStack(spacing: 25) {
                                ForEach(["😊", "😐", "😢", "😡", "😴"], id: \.self) { emoji in
                                    Button(action: {
                                        selectedMood = emoji
                                    }) {
                                        Text(emoji)
                                            .font(.system(size: 40))
                                            .padding()
                                            .background(
                                                Circle()
                                                    .fill(selectedMood == emoji ? 
                                                          Color.white : Color.clear)
                                                    .shadow(color: selectedMood == emoji ? 
                                                            ColorTheme.primaryPink.opacity(0.3) : Color.clear, 
                                                            radius: 5, x: 0, y: 3)
                                            )
                                    }
                                }
                            }
                            .padding(.vertical, 10)
                            
                            Text("Add notes (optional)")
                                .font(.subheadline)
                                .foregroundColor(ColorTheme.textGray)
                            
                            TextEditor(text: $notes)
                                .frame(height: 100)
                                .padding(5)
                                .background(Color.white.opacity(0.8))
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                )
                            
                            Button(action: {
                                // Save mood logic would go here
                                showingSuccess = true
                                
                                // Clear the form after a delay
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    showingSuccess = false
                                    notes = ""
                                }
                            }) {
                                Text("Save Today's Mood")
                                    .fontWeight(.medium)
                                    .foregroundColor(.white)
                                    .padding(.vertical, 12)
                                    .frame(maxWidth: .infinity)
                                    .background(ColorTheme.buttonGradient)
                                    .cornerRadius(15)
                                    .shadow(color: ColorTheme.primaryPink.opacity(0.3), radius: 5, x: 0, y: 3)
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(20)
                        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                        .padding(.horizontal)
                        .overlay(
                            ZStack {
                                if showingSuccess {
                                    VStack {
                                        Text("Mood Saved!")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                            .padding()
                                            .background(ColorTheme.primaryPink)
                                            .cornerRadius(10)
                                            .shadow(radius: 5)
                                            .transition(.scale.combined(with: .opacity))
                                    }
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .background(Color.black.opacity(0.3))
                                    .cornerRadius(20)
                                }
                            }
                            .animation(.easeInOut, value: showingSuccess)
                        )
                        
                        // Mood History
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Your Mood History")
                                .font(.headline)
                                .foregroundColor(ColorTheme.textGray)
                                .padding(.horizontal)
                            
                            VStack(spacing: 0) {
                                ForEach(moodHistory, id: \.date) { entry in
                                    MoodHistoryRow(entry: entry)
                                    
                                    if entry != moodHistory.last {
                                        Divider()
                                            .background(Color.gray.opacity(0.2))
                                            .padding(.leading, 70)
                                    }
                                }
                            }
                            .background(Color.white.opacity(0.8))
                            .cornerRadius(15)
                            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 3)
                            .padding(.horizontal)
                        }
                        
                        Spacer(minLength: 50)
                    }
                    .padding(.top)
                }
            }
            .navigationTitle("Mood Tracker")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct MoodEntry {
    let date: Date
    let mood: String
    let notes: String
}

struct MoodHistoryRow: View {
    let entry: MoodEntry
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    var body: some View {
        HStack(spacing: 15) {
            Text(entry.mood)
                .font(.system(size: 30))
                .frame(width: 50)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(dateFormatter.string(from: entry.date))
                    .font(.subheadline)
                    .foregroundColor(ColorTheme.textGray)
                
                if !entry.notes.isEmpty {
                    Text(entry.notes)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
            }
            
            Spacer()
        }
        .padding()
    }
}

struct MoodTrackerView_Previews: PreviewProvider {
    static var previews: some View {
        MoodTrackerView()
    }
}
