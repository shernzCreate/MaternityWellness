import Foundation
import Combine

class ResourceViewModel: ObservableObject {
    @Published var userId: String
    @Published var allResources: [Resource] = []
    @Published var featuredResources: [Resource] = []
    @Published var categorizedResources: [ResourceCategory: [Resource]] = [:]
    @Published var bookmarkedResources: Set<String> = []
    @Published var resourceProgress: [String: Double] = [:]
    @Published var searchQuery: String = ""
    @Published var searchResults: [Resource] = []
    @Published var selectedCategory: ResourceCategory?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    init(userId: String) {
        self.userId = userId
        loadResources()
        loadBookmarks()
        loadProgress()
    }
    
    func loadResources() {
        isLoading = true
        errorMessage = nil
        
        // In a real implementation, would fetch from API
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // For demo purposes, load sample data
            self.loadSampleResources()
            self.isLoading = false
        }
    }
    
    func loadBookmarks() {
        // In a real implementation, would fetch from API or local storage
        // For demo purposes, set a few random bookmarks
        for resource in allResources.prefix(3) {
            bookmarkedResources.insert(resource.id)
        }
    }
    
    func loadProgress() {
        // In a real implementation, would fetch from API or local storage
        // For demo purposes, set random progress for a few resources
        for resource in allResources.prefix(5) {
            resourceProgress[resource.id] = Double.random(in: 0.1...0.9)
        }
    }
    
    func searchResources() {
        guard !searchQuery.isEmpty else {
            searchResults = []
            return
        }
        
        let query = searchQuery.lowercased()
        searchResults = allResources.filter { resource in
            resource.title.lowercased().contains(query) ||
            resource.description.lowercased().contains(query) ||
            resource.content.lowercased().contains(query) ||
            resource.tags.contains { $0.lowercased().contains(query) }
        }
    }
    
    func toggleBookmark(resourceId: String) {
        if bookmarkedResources.contains(resourceId) {
            bookmarkedResources.remove(resourceId)
        } else {
            bookmarkedResources.insert(resourceId)
        }
        
        // In a real implementation, would save to API
    }
    
    func updateResourceProgress(resourceId: String, progress: Double) {
        resourceProgress[resourceId] = progress
        
        // In a real implementation, would save to API
    }
    
    func getBookmarkedResources() -> [Resource] {
        return allResources.filter { bookmarkedResources.contains($0.id) }
    }
    
    func getResourcesInProgress() -> [Resource] {
        return allResources.filter { 
            if let progress = resourceProgress[$0.id] {
                return progress > 0 && progress < 1.0
            }
            return false
        }
    }
    
    func getRelatedResources(for resource: Resource, limit: Int) -> [Resource] {
        // Find resources with the same category or shared tags
        let related = allResources.filter { otherResource in
            if otherResource.id == resource.id { return false }
            
            if otherResource.category == resource.category { return true }
            
            // Check for shared tags
            for tag in resource.tags {
                if otherResource.tags.contains(tag) { return true }
            }
            
            return false
        }
        
        // Return up to the limit number of related resources
        if related.count <= limit {
            return related
        } else {
            return Array(related.prefix(limit))
        }
    }
    
    func setCategory(_ category: ResourceCategory?) {
        selectedCategory = category
    }
    
    // For demo purposes only - load sample resources
    private func loadSampleResources() {
        // Clear existing data
        allResources = []
        featuredResources = []
        categorizedResources = [:]
        
        // Create Singapore-specific resources
        
        // KK Women's and Children's Hospital resources
        let kkHospitalResource = Resource(
            title: "KK Hospital Postnatal Support Services",
            description: "Learn about the comprehensive postnatal care services available at KK Women's and Children's Hospital in Singapore.",
            content: "KK Women's and Children's Hospital (KKH) offers a range of postnatal support services to help new mothers during this important transition period. Services include:\n\n• Breastfeeding support with certified lactation consultants\n• Postnatal depression screening and counseling\n• Parent craft classes\n• 24-hour helpline for new parents\n• Baby care workshops\n\nTo schedule an appointment, call the KKH Women's Mental Wellness Service at 6394-1000.",
            type: .article,
            category: .singaporeResources,
            source: "KK Women's and Children's Hospital",
            readTime: 5,
            featured: true,
            tags: ["Singapore", "Healthcare", "Support Services", "Postnatal Care"]
        )
        
        // NUH resources
        let nuhResource = Resource(
            title: "National University Hospital Women's Mental Wellness Program",
            description: "Information about NUH's specialized mental health services for new and expecting mothers in Singapore.",
            content: "The Women's Mental Wellness Program at National University Hospital provides comprehensive psychiatric and psychological care for women during pregnancy and after childbirth. Their multidisciplinary team includes psychiatrists, psychologists, and maternal-fetal medicine specialists who work together to provide holistic care.\n\nServices include:\n• Preconception counseling\n• Antenatal and postnatal depression screening\n• Medication management during pregnancy and breastfeeding\n• Individual and group therapy\n\nTo make an appointment, call the NUH Women's Clinic at 6772-2002.",
            type: .article,
            category: .singaporeResources,
            source: "National University Hospital",
            readTime: 7,
            tags: ["Singapore", "Mental Health", "Healthcare", "Pregnancy"]
        )
        
        // MOH resources
        let mohResource = Resource(
            title: "Ministry of Health Singapore Postnatal Care Guidelines",
            description: "Official guidelines from Singapore's Ministry of Health on postnatal care practices for new mothers.",
            content: "The Ministry of Health Singapore provides evidence-based guidelines for postnatal care to ensure the well-being of new mothers and their babies. These guidelines cover:\n\n• Recommended postnatal check-up schedule\n• Physical recovery after childbirth\n• Emotional health screening and support\n• Breastfeeding best practices\n• When to seek medical attention\n• Community resources for new parents\n\nThese guidelines are used by healthcare providers across Singapore to deliver consistent, high-quality postnatal care.",
            type: .article,
            category: .singaporeResources,
            source: "Ministry of Health Singapore",
            readTime: 10,
            tags: ["Singapore", "Healthcare Policy", "Guidelines", "Postnatal Care"]
        )
        
        // Singapore Postpartum Depression Support Groups
        let supportGroupResource = Resource(
            title: "Postpartum Support Groups in Singapore",
            description: "A comprehensive list of support groups and community resources for mothers experiencing postpartum depression in Singapore.",
            content: "Finding support from others who understand what you're going through can be invaluable during the postpartum period. Singapore offers several support groups specifically for mothers experiencing postpartum depression or anxiety:\n\n• Postnatal Depression Support Group (KK Hospital): Monthly meetings facilitated by mental health professionals. Call 6394-1000 for details.\n\n• Mother & Child Wellness Support Group (NUH): Bi-weekly sessions for mothers struggling with perinatal mood disorders. Register at 6772-2037.\n\n• Singapore Motherhood Forum: Online community with a dedicated section for postnatal mental health discussions.\n\n• Breastfeeding Mothers' Support Group: While focused on breastfeeding, this group also provides emotional support for new mothers. Visit www.bmsg.org for meeting schedules.\n\n• Singapore Association for Mental Health (SAMH): Offers counseling services and support programs for various mental health conditions, including postpartum depression. Contact 1800-283-7019.",
            type: .article,
            category: .singaporeResources,
            readTime: 6,
            featured: true,
            tags: ["Singapore", "Support Groups", "Community Resources", "Peer Support"]
        )
        
        // Educational resources
        let whatIsPpdResource = Resource(
            title: "Understanding Postpartum Depression",
            description: "Learn about the symptoms, causes, and treatments for postpartum depression.",
            content: "Postpartum depression (PPD) is a serious mental health condition that affects approximately 1 in 7 women after childbirth. Unlike the \"baby blues,\" which typically resolve within two weeks, PPD can persist for months or even years if left untreated.\n\nSymptoms may include:\n• Persistent feelings of sadness, emptiness, or hopelessness\n• Loss of interest in activities once enjoyed\n• Feeling disconnected from your baby\n• Changes in appetite and sleep patterns\n• Difficulty concentrating or making decisions\n• Thoughts of harming yourself or your baby\n\nPPD is caused by a combination of physical, emotional, and hormonal factors. Risk factors include a personal or family history of depression, relationship problems, complications during pregnancy or birth, and lack of social support.\n\nTreatment options include therapy (especially cognitive-behavioral therapy), medication (antidepressants), and support groups. With proper treatment, most women fully recover from PPD.",
            type: .article,
            category: .mentalHealth,
            readTime: 8,
            featured: true,
            tags: ["Depression", "Postpartum", "Mental Health", "Symptoms"]
        )
        
        let ppd_video = Resource(
            title: "Recognizing and Coping with Postpartum Depression",
            description: "An informative video featuring healthcare professionals and mothers discussing symptoms and strategies for managing postpartum depression.",
            content: "This video features interviews with mental health experts and testimonials from mothers who have experienced postpartum depression. Topics covered include:\n\n- How to distinguish between baby blues and postpartum depression\n- Common symptoms that may be overlooked\n- When and how to seek professional help\n- Self-care strategies for new mothers\n- How partners and family members can provide support",
            type: .video,
            category: .mentalHealth,
            source: "Women's Mental Health Consortium",
            readTime: 15,
            videoUrl: "https://example.com/videos/ppd-coping",
            tags: ["Depression", "Video", "Coping Strategies", "Self-Care"]
        )
        
        let effects_on_family = Resource(
            title: "How Postpartum Depression Affects the Whole Family",
            description: "Understanding the impact of maternal postpartum depression on partners, children, and family dynamics.",
            content: "Postpartum depression doesn't just affect the mother—it impacts the entire family system. This article explores how PPD can influence:\n\n• The mother-infant bond and attachment patterns\n• Partner relationships and the increased risk of depression in partners\n• Development of older children in the home\n• Overall family functioning and communication\n\nThe article also provides practical guidance for family members on how to support a mother with PPD while also taking care of their own mental health needs. Understanding these dynamics is crucial for developing comprehensive treatment approaches that address the needs of all family members.",
            type: .article,
            category: .relationships,
            readTime: 12,
            tags: ["Family Dynamics", "Partners", "Children", "Support Systems"]
        )
        
        let postpartum_exercise = Resource(
            title: "Safe and Effective Postpartum Exercises",
            description: "A guide to gradually returning to physical activity after childbirth, with specific exercises designed for new mothers.",
            content: "Regular physical activity can help improve mood, increase energy levels, and promote recovery after childbirth. This guide offers a progressive approach to postpartum exercise, beginning with gentle movements that can be started within days of delivery (with medical clearance) and advancing to more challenging workouts as your body heals.\n\nFeatured exercises include:\n• Diaphragmatic breathing and gentle pelvic floor exercises\n• Posture correction and alignment techniques\n• Progressive core strengthening to address diastasis recti\n• Low-impact cardiovascular activities to boost mood and energy\n• Full-body strength exercises that accommodate caring for a newborn\n\nEach exercise includes modifications for different postpartum stages and considerations for mothers recovering from C-sections or complicated deliveries.",
            type: .exercise,
            category: .physicalHealth,
            readTime: 15,
            tags: ["Exercise", "Physical Recovery", "Fitness", "Self-Care"]
        )
        
        let nutrition_resource = Resource(
            title: "Postpartum Nutrition for Recovery and Breastfeeding",
            description: "Nutritional guidelines to support physical recovery, mental health, and successful breastfeeding.",
            content: "Proper nutrition during the postpartum period plays a crucial role in physical recovery, mental wellbeing, and breastfeeding success. This comprehensive guide covers:\n\n• Calorie and nutrient needs for recovering mothers\n• Foods that may help stabilize mood and energy levels\n• Nutritional requirements for breastfeeding mothers\n• Hydration strategies for postpartum and lactation\n• Quick and easy meal ideas for busy new parents\n• Cultural postpartum nutrition practices from around the world, including traditional Singaporean confinement foods\n\nThe guide emphasizes practical, realistic approaches to nutrition during this demanding life stage, acknowledging that perfect eating habits are less important than finding sustainable ways to nourish yourself while caring for a newborn.",
            type: .article,
            category: .nutrition,
            readTime: 10,
            tags: ["Nutrition", "Breastfeeding", "Recovery", "Meal Planning"]
        )
        
        let sleep_strategies = Resource(
            title: "Sleep Strategies for New Parents",
            description: "Practical techniques to maximize sleep quality and quantity during the challenging postpartum period.",
            content: "Sleep deprivation is one of the most challenging aspects of early parenthood and can significantly impact mental health. This guide provides evidence-based strategies to help new parents optimize their sleep despite the irregular schedule of caring for a newborn.\n\nTopics include:\n• Setting up sleep-friendly environments\n• The \"sleep when the baby sleeps\" approach: pros and cons\n• Safe co-sleeping practices\n• Sleep scheduling and shift systems for partners\n• Recognizing when sleep problems may indicate depression\n• When and how to ask for overnight help\n\nThe guide acknowledges that there is no one-size-fits-all approach to postpartum sleep and offers various options that can be adapted to different family situations and parenting philosophies.",
            type: .article,
            category: .sleep,
            readTime: 9,
            tags: ["Sleep", "Fatigue", "Self-Care", "Newborn Care"]
        )
        
        // Add all resources to the main collection
        allResources = [
            kkHospitalResource,
            nuhResource, 
            mohResource,
            supportGroupResource,
            whatIsPpdResource,
            ppd_video,
            effects_on_family,
            postpartum_exercise,
            nutrition_resource,
            sleep_strategies
        ]
        
        // Set featured resources
        featuredResources = allResources.filter { $0.featured }
        
        // If we don't have enough featured resources, add some
        if featuredResources.count < 3 {
            featuredResources = Array(allResources.prefix(3))
        }
        
        // Organize by category
        for resource in allResources {
            if categorizedResources[resource.category] == nil {
                categorizedResources[resource.category] = []
            }
            categorizedResources[resource.category]?.append(resource)
        }
    }
}