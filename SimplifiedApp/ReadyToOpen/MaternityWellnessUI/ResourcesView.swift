import SwiftUI

struct ResourcesView: View {
    @State private var selectedCategory: ResourceCategory = .ppd
    
    var body: some View {
        NavigationView {
            ZStack {
                ColorTheme.backgroundGradient
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    // Category selector
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(ResourceCategory.allCases, id: \.self) { category in
                                CategoryButton(
                                    title: category.title,
                                    isSelected: selectedCategory == category,
                                    action: { selectedCategory = category }
                                )
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 10)
                    }
                    
                    // Resources list
                    ScrollView {
                        LazyVStack(spacing: 15) {
                            ForEach(resourcesFor(category: selectedCategory), id: \.title) { resource in
                                ResourceCard(resource: resource)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 10)
                    }
                }
            }
            .navigationTitle("Resources")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    func resourcesFor(category: ResourceCategory) -> [Resource] {
        switch category {
        case .ppd:
            return ppdResources
        case .support:
            return supportResources
        case .selfCare:
            return selfCareResources
        case .localInfo:
            return localResources
        }
    }
}

struct CategoryButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .medium)
                .foregroundColor(isSelected ? .white : ColorTheme.textGray)
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(isSelected ? ColorTheme.buttonGradient : Color.white.opacity(0.8))
                .cornerRadius(20)
                .shadow(color: isSelected ? ColorTheme.primaryPink.opacity(0.3) : Color.black.opacity(0.05), radius: 5, x: 0, y: 3)
        }
    }
}

struct ResourceCard: View {
    let resource: Resource
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: resource.iconName)
                    .font(.title2)
                    .foregroundColor(ColorTheme.primaryPink)
                    .frame(width: 30)
                
                Text(resource.title)
                    .font(.headline)
                    .foregroundColor(ColorTheme.textGray)
                
                Spacer()
                
                Button(action: {
                    withAnimation {
                        isExpanded.toggle()
                    }
                }) {
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(ColorTheme.textGray)
                }
            }
            
            if isExpanded {
                VStack(alignment: .leading, spacing: 10) {
                    Text(resource.description)
                        .font(.subheadline)
                        .foregroundColor(ColorTheme.textGray)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    if let source = resource.source {
                        Text("Source: \(source)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    if resource.hasLink {
                        HStack {
                            Spacer()
                            
                            Button(action: {
                                // In a real app, this would open the link
                            }) {
                                Text("Open Resource")
                                    .font(.footnote)
                                    .fontWeight(.medium)
                                    .foregroundColor(.white)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 16)
                                    .background(ColorTheme.buttonGradient)
                                    .cornerRadius(15)
                                    .shadow(color: ColorTheme.primaryPink.opacity(0.3), radius: 5, x: 0, y: 3)
                            }
                        }
                    }
                }
                .padding(.top, 5)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding()
        .background(Color.white.opacity(0.8))
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 3)
    }
}

struct Resource {
    let title: String
    let description: String
    let iconName: String
    let source: String?
    let url: String?
    
    var hasLink: Bool {
        url != nil
    }
}

enum ResourceCategory: CaseIterable {
    case ppd
    case support
    case selfCare
    case localInfo
    
    var title: String {
        switch self {
        case .ppd:
            return "About PPD"
        case .support:
            return "Support"
        case .selfCare:
            return "Self-Care"
        case .localInfo:
            return "Singapore"
        }
    }
}

// Sample Resources
let ppdResources = [
    Resource(
        title: "What is Postpartum Depression?",
        description: "Postpartum depression (PPD) is a complex mix of physical, emotional, and behavioral changes that occur after giving birth. It's a form of depression that affects approximately 1 in 7 women following childbirth. PPD is different from the 'baby blues,' which typically resolve within two weeks.",
        iconName: "doc.text",
        source: "KK Women's and Children's Hospital",
        url: "https://www.kkh.com.sg"
    ),
    Resource(
        title: "Signs and Symptoms",
        description: "Symptoms of PPD may include persistent sadness, difficulty bonding with the baby, withdrawing from family and friends, loss of interest in activities, changes in appetite or sleep, overwhelming fatigue, reduced interest in activities, intense irritability and anger, fear of not being a good mother, and thoughts of harming yourself or your baby.",
        iconName: "list.bullet",
        source: "Singapore Ministry of Health",
        url: "https://www.moh.gov.sg"
    ),
    Resource(
        title: "Risk Factors",
        description: "Factors that may increase your risk of developing PPD include a history of depression, a difficult pregnancy or birth experience, having a baby with health problems, lack of support from family or friends, financial stress, and major recent life changes.",
        iconName: "exclamationmark.triangle",
        source: "National University Hospital Singapore",
        url: "https://www.nuh.com.sg"
    ),
    Resource(
        title: "Treatment Options",
        description: "PPD can be treated with a combination of counseling (talk therapy), medication, and lifestyle changes. Many women with PPD show significant improvement with treatment. Early identification and intervention are important for better outcomes.",
        iconName: "heart.text.square",
        source: "Singapore Association for Mental Health",
        url: "https://www.samhealth.org.sg"
    )
]

let supportResources = [
    Resource(
        title: "National Care Hotline",
        description: "The National CARE Hotline provides psychological first aid and emotional support to anyone facing mental health challenges. Available 24/7.",
        iconName: "phone.fill",
        source: "Ministry of Social and Family Development",
        url: "tel:1800-202-6868"
    ),
    Resource(
        title: "Singapore Association for Mental Health (SAMH)",
        description: "SAMH provides mental health services including counseling and support groups for various mental health conditions including postpartum depression.",
        iconName: "person.2.fill",
        source: "SAMH",
        url: "https://www.samhealth.org.sg"
    ),
    Resource(
        title: "KK Women's and Children's Hospital Mental Wellness Service",
        description: "KKH offers specialized mental health services for women experiencing perinatal mental health issues, including postpartum depression.",
        iconName: "building.2.fill",
        source: "KKH",
        url: "https://www.kkh.com.sg"
    ),
    Resource(
        title: "Parent Support Groups",
        description: "Various community organizations in Singapore offer support groups specifically for new parents dealing with the challenges of parenthood.",
        iconName: "person.3.fill",
        source: "Baby Bonus Parenting Resources",
        url: "https://www.babybonus.msf.gov.sg"
    )
]

let selfCareResources = [
    Resource(
        title: "Mindfulness for New Mothers",
        description: "Simple mindfulness exercises that can be practiced in just a few minutes a day to reduce stress and anxiety. These can be done even while caring for your baby.",
        iconName: "brain.head.profile",
        source: nil,
        url: nil
    ),
    Resource(
        title: "Sleep Strategies",
        description: "Practical tips for improving sleep quality when caring for a newborn, including napping when the baby naps, asking for help with night feedings, and creating a restful environment.",
        iconName: "bed.double.fill",
        source: nil,
        url: nil
    ),
    Resource(
        title: "Nutrition for Postpartum Recovery",
        description: "Food suggestions that can help with energy levels, mood regulation, and physical recovery after childbirth. Includes meal prep ideas that are quick and nutritious.",
        iconName: "fork.knife",
        source: "Health Promotion Board Singapore",
        url: "https://www.healthhub.sg"
    ),
    Resource(
        title: "Gentle Exercise for New Mothers",
        description: "Safe, gentle exercises that can be started after getting medical clearance, to help improve mood, energy levels, and physical recovery.",
        iconName: "figure.walk",
        source: nil,
        url: nil
    )
]

let localResources = [
    Resource(
        title: "KK Women's and Children's Hospital Postnatal Services",
        description: "KKH provides comprehensive postnatal care services including home visits, breastfeeding support, and mental health screening for new mothers.",
        iconName: "cross.fill",
        source: "KKH",
        url: "https://www.kkh.com.sg/patient-care/areas-of-care/womens-services"
    ),
    Resource(
        title: "National University Hospital Women's Centre",
        description: "NUH Women's Centre offers specialized care for women including postnatal care and mental health support for new mothers.",
        iconName: "cross.fill",
        source: "NUH",
        url: "https://www.nuh.com.sg/our-services/Specialties/Obstetrics-Gynaecology/Pages/default.aspx"
    ),
    Resource(
        title: "Community Health Assist Scheme (CHAS)",
        description: "CHAS enables Singapore citizens to receive subsidies for medical and dental care at participating clinics near their homes, including mental health services.",
        iconName: "dollarsign.square.fill",
        source: "Ministry of Health",
        url: "https://www.chas.sg"
    ),
    Resource(
        title: "Baby Bonus Parenting Resources",
        description: "The Baby Bonus Parenting Resources portal provides information and resources for parents in Singapore, including articles, videos, and listings of parent support groups.",
        iconName: "figure.and.child.holdinghands",
        source: "Ministry of Social and Family Development",
        url: "https://www.babybonus.msf.gov.sg"
    )
]

struct ResourcesView_Previews: PreviewProvider {
    static var previews: some View {
        ResourcesView()
    }
}
