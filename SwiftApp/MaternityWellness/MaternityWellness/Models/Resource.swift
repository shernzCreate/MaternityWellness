import SwiftUI

enum ResourceType: String, Codable {
    case article = "Article"
    case video = "Video"
}

enum ResourceCategory: String, CaseIterable, Codable {
    case all = "All"
    case mental = "Mental Health"
    case physical = "Physical Health"
    case baby = "Baby Care"
    case medical = "Medical"
    case support = "Support"
    case parenting = "Parenting"
    
    var color: Color {
        switch self {
        case .all:
            return Color.gray
        case .mental:
            return Color.purple
        case .physical:
            return Color.blue
        case .baby:
            return Color.pink
        case .medical:
            return Color.red
        case .support:
            return Color.green
        case .parenting:
            return Color.orange
        }
    }
}

struct Resource: Identifiable, Codable {
    let id: Int
    let title: String
    let description: String
    let content: String
    let type: ResourceType
    let category: ResourceCategory
    let readTimeMinutes: Int
    let author: String?
    let source: String?
    let datePublished: Date
    let isFeatured: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case content
        case type
        case category
        case readTimeMinutes = "read_time_minutes"
        case author
        case source
        case datePublished = "date_published"
        case isFeatured = "is_featured"
    }
}

class ResourceViewModel: ObservableObject {
    @Published var resources: [Resource] = []
    @Published var featuredResources: [Resource] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    
    func loadResources() {
        isLoading = true
        
        // In a real app, this would be an API call
        // For demo purposes, we'll load sample data
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.resources = self.getSampleResources()
            self.featuredResources = self.resources.filter { $0.isFeatured }
            self.isLoading = false
        }
    }
    
    func getResourcesByCategory(category: ResourceCategory) -> [Resource] {
        if category == .all {
            return resources
        } else {
            return resources.filter { $0.category == category }
        }
    }
    
    // Sample resource data for demonstration purposes
    private func getSampleResources() -> [Resource] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let singaporeResources: [Resource] = [
            // Mental Health Resources
            Resource(
                id: 1,
                title: "Understanding Postnatal Depression",
                description: "Learn about the symptoms, causes, and treatments for postnatal depression in new mothers.",
                content: """
                Postnatal depression (PND) is a type of depression that many parents experience after having a baby. It's a common problem, affecting more than 1 in 10 women within a year of giving birth. It can also affect fathers and partners.
                
                Unlike the 'baby blues' (which is experienced by up to 80% of mothers) PND usually develops within the first few months after giving birth, particularly in the first five weeks. However, it can start at any time during the first year.
                
                ## Symptoms of Postnatal Depression
                
                The symptoms of PND are similar to those of depression at other times. These can include:
                
                - Persistent feelings of sadness and low mood
                - Loss of interest in the world around you and no longer enjoying things that used to give you pleasure
                - Lack of energy and feeling tired all the time
                - Trouble sleeping at night and feeling sleepy during the day
                - Feeling that you're unable to look after your baby
                - Problems concentrating and making decisions
                - Loss of appetite or increased appetite (comfort eating)
                - Feelings of guilt, hopelessness and self-blame
                - Difficulty bonding with your baby
                - Frightening thoughts – for example, about hurting your baby
                
                ## Getting Help
                
                It's important to seek help as soon as possible if you think you might be depressed, as your symptoms could last months or get worse and have a significant impact on you, your baby and your family.
                
                Treatment options include:
                
                - Self-help strategies
                - Therapy
                - Medication
                
                With the right support, most women make a full recovery from PND.
                """,
                type: .article,
                category: .mental,
                readTimeMinutes: 5,
                author: "KK Women's and Children's Hospital",
                source: "KK Hospital Mental Health Service",
                datePublished: dateFormatter.date(from: "2023-06-15")!,
                isFeatured: true
            ),
            
            Resource(
                id: 2,
                title: "Physical Recovery After Childbirth",
                description: "A guide to physical recovery in the weeks and months after giving birth.",
                content: """
                ## Physical Recovery After Childbirth
                
                Your body has been through an enormous change and it will take time to recover. Be patient with yourself and focus on taking care of yourself as well as your baby.
                
                ### First Six Weeks
                
                During the first six weeks, you may experience:
                
                - Vaginal discharge (lochia) that changes from bright red to brownish to yellow-white
                - Afterpains – contractions that help your uterus return to its pre-pregnancy size
                - Breast engorgement when your milk comes in
                - Sore nipples if you're breastfeeding
                - Constipation and hemorrhoids
                - Sweating, especially at night
                - Urinary incontinence
                - Soreness, if you had a tear or episiotomy during vaginal delivery
                - Incision pain, if you had a C-section
                
                ### Self-care Tips
                
                - Rest as much as possible
                - Accept help from family and friends
                - Drink plenty of fluids, especially if you're breastfeeding
                - Eat nutritious foods
                - Do gentle exercises, such as pelvic floor exercises
                - Don't expect your body to return to its pre-pregnancy state quickly
                
                ### When to See a Doctor
                
                Contact your healthcare provider if you experience:
                
                - Heavy vaginal bleeding that soaks more than one pad per hour
                - Severe pain
                - A fever
                - Redness or discharge from a C-section incision
                - Painful urination
                - Severe headaches
                - Feelings of depression that interfere with caring for yourself or your baby
                
                Remember that your body has accomplished something remarkable and deserves time to heal.
                """,
                type: .article,
                category: .physical,
                readTimeMinutes: 6,
                author: "Singapore General Hospital",
                source: "SGH Women's Health",
                datePublished: dateFormatter.date(from: "2023-04-22")!,
                isFeatured: false
            ),
            
            Resource(
                id: 3,
                title: "Breastfeeding Tips for New Mothers",
                description: "Practical advice for successful breastfeeding from Singapore lactation consultants.",
                content: """
                ## Breastfeeding Tips for New Mothers
                
                Breastfeeding is a natural process, but it can take time and practice for both you and your baby to get it right. Here are some tips to help you on your breastfeeding journey.
                
                ### Getting Started
                
                - Start breastfeeding as soon as possible after birth
                - Ensure good positioning and attachment
                - Feed your baby on demand – usually 8-12 times in 24 hours for newborns
                - Look for feeding cues: rooting, putting hands to mouth, sucking motions
                
                ### Common Challenges
                
                #### Sore Nipples
                - Ensure correct latch – baby should have a large mouthful of breast
                - Break suction carefully by inserting a clean finger between baby's gums
                - Apply expressed breast milk to nipples after feeding
                - Consider seeing a lactation consultant if pain persists
                
                #### Engorgement
                - Feed frequently
                - Apply warm compresses before feeding
                - Apply cold compresses after feeding
                - Express a little milk if needed to soften the areola
                
                #### Low Milk Supply
                - Feed more frequently
                - Ensure baby is latched well and swallowing
                - Stay hydrated and eat nutritious foods
                - Rest as much as possible
                
                ### Local Support Resources
                
                - Breastfeeding Mothers' Support Group (Singapore)
                - KK Hospital Lactation Service
                - National University Hospital Lactation Services
                - Community lactation consultants
                
                Remember that breastfeeding is a learning process. With patience and support, most mothers can breastfeed successfully.
                """,
                type: .article,
                category: .baby,
                readTimeMinutes: 7,
                author: "Breastfeeding Mothers' Support Group Singapore",
                source: "BMSG Singapore",
                datePublished: dateFormatter.date(from: "2023-03-10")!,
                isFeatured: false
            ),
            
            Resource(
                id: 4,
                title: "Recognizing Perinatal Anxiety",
                description: "How to identify symptoms of anxiety during pregnancy and postpartum period.",
                content: """
                ## Recognizing Perinatal Anxiety
                
                Anxiety during pregnancy and after childbirth is common but often overlooked. Understanding the symptoms can help you seek appropriate support.
                
                ### Types of Perinatal Anxiety
                
                #### Generalized Anxiety
                - Persistent worry about multiple issues
                - Difficulty controlling worry
                - Restlessness or feeling on edge
                - Fatigue
                - Difficulty concentrating
                - Irritability
                - Muscle tension
                - Sleep disturbance
                
                #### Panic Disorder
                - Sudden episodes of intense fear
                - Heart palpitations
                - Shortness of breath
                - Dizziness
                - Feeling of losing control
                
                #### Obsessive-Compulsive Disorder (OCD)
                - Intrusive, unwanted thoughts, often about harm coming to the baby
                - Compulsive behaviors or mental acts aimed at reducing anxiety
                
                ### Risk Factors
                
                - History of anxiety or other mental health conditions
                - Family history of anxiety
                - Pregnancy complications
                - Previous pregnancy loss
                - Traumatic childbirth experience
                - Limited social support
                - Major life stressors
                
                ### Getting Help
                
                If you're experiencing symptoms of anxiety that interfere with your daily functioning or enjoyment of life, please seek help. Treatment options include:
                
                - Cognitive Behavioral Therapy (CBT)
                - Mindfulness techniques
                - Medication (when appropriate)
                - Support groups
                
                In Singapore, you can access mental health support through:
                
                - Your obstetrician or gynecologist
                - KK Hospital's Women's Mental Wellness Service
                - National University Hospital's Psychological Medicine Department
                - Singapore General Hospital's Department of Psychiatry
                
                Remember that seeking help is a sign of strength, not weakness.
                """,
                type: .article,
                category: .mental,
                readTimeMinutes: 5,
                author: "Dr. Chen Liying",
                source: "Singapore Association for Mental Health",
                datePublished: dateFormatter.date(from: "2023-02-28")!,
                isFeatured: true
            ),
            
            Resource(
                id: 5,
                title: "Essential Newborn Care",
                description: "A comprehensive guide to caring for your newborn in the first few weeks.",
                content: """
                ## Essential Newborn Care
                
                The first few weeks with your newborn can be both exciting and overwhelming. Here's a guide to help you care for your baby with confidence.
                
                ### Feeding
                
                Whether you're breastfeeding or formula feeding, your newborn will need to eat frequently – usually every 2-3 hours.
                
                - For breastfed babies: Feed on demand, usually 8-12 times in 24 hours
                - For formula-fed babies: Offer 1-3 ounces every 2-4 hours
                - Hold baby semi-upright during and after feeds
                - Burp baby after each feeding
                
                ### Sleep
                
                Newborns sleep about 16 hours a day, but only for short periods of 2-4 hours.
                
                - Always place baby on back to sleep
                - Use a firm mattress with fitted sheet
                - Keep soft objects and loose bedding out of the crib
                - Consider room-sharing but not bed-sharing
                - Establish a simple bedtime routine
                
                ### Diapering
                
                Expect to change 8-10 diapers per day in the first few weeks.
                
                - Change diapers frequently to prevent diaper rash
                - Clean the genital area thoroughly with each change
                - For girls, wipe from front to back
                - Allow some air time when possible
                - Apply barrier cream if needed
                
                ### Bathing
                
                Until the umbilical cord stump falls off, stick to sponge baths.
                
                - Bath 2-3 times a week is sufficient
                - Gather all supplies before starting
                - Never leave baby unattended in water
                - Keep room warm and free of drafts
                - Use mild, fragrance-free soap
                
                ### Umbilical Cord Care
                
                - Keep the stump clean and dry
                - Fold diaper below the stump
                - Clean with water if it becomes dirty
                - Avoid submerging in water until it falls off (usually 1-2 weeks)
                
                ### When to Call the Doctor
                
                - Fever (rectal temperature above 38°C)
                - Poor feeding
                - Extreme sleepiness or difficulty waking
                - Yellowing of skin or eyes
                - Fewer wet diapers than normal
                - Redness, discharge, or odor around umbilical cord
                
                Remember, no parent knows everything at the start. You'll become more confident with each day.
                """,
                type: .article,
                category: .baby,
                readTimeMinutes: 8,
                author: "KK Women's and Children's Hospital",
                source: "KK Hospital Department of Neonatology",
                datePublished: dateFormatter.date(from: "2023-05-15")!,
                isFeatured: false
            ),
            
            Resource(
                id: 6,
                title: "Postnatal Exercise Guide",
                description: "Safe and effective exercises for postpartum recovery.",
                content: """
                ## Postnatal Exercise Guide
                
                Returning to exercise after childbirth should be gradual and tailored to your individual recovery. This guide provides safe exercises to help restore strength and fitness.
                
                ### When to Start
                
                - After vaginal delivery: You can begin gentle exercises like pelvic floor exercises and walking within days
                - After cesarean delivery: Wait until your 6-week check-up before starting any exercise program beyond gentle walking
                - Always get clearance from your healthcare provider
                
                ### Pelvic Floor Exercises (Kegels)
                
                These can be started immediately after birth:
                
                1. Identify the pelvic floor muscles (the ones you use to stop urination)
                2. Tighten these muscles and hold for 5-10 seconds
                3. Relax for 5-10 seconds
                4. Repeat 10 times, 3 times daily
                
                ### Abdominal Breathing
                
                1. Lie on your back with knees bent
                2. Place hands on abdomen
                3. Inhale deeply through your nose, feeling your abdomen rise
                4. Exhale slowly through your mouth, feeling your abdomen fall
                5. Repeat 10 times
                
                ### Gentle Abdominal Exercise
                
                1. Lie on your back with knees bent
                2. Exhale and gently draw in your lower abdomen
                3. Hold for 5-10 seconds while breathing normally
                4. Release and repeat 10 times
                
                ### Progressive Exercises (from 6 weeks, with doctor's approval)
                
                #### Modified Plank
                1. Start on hands and knees
                2. Keep back straight and engage abdominal muscles
                3. Hold for 15-30 seconds
                4. Repeat 3-5 times
                
                #### Pelvic Tilts
                1. Lie on back with knees bent
                2. Flatten lower back against floor by tilting pelvis
                3. Hold for 5 seconds, then release
                4. Repeat 10 times
                
                ### Important Considerations
                
                - Listen to your body and stop if you feel pain
                - Watch for signs you're doing too much: increased bleeding, pain, fatigue
                - Stay hydrated, especially if breastfeeding
                - Wear a supportive bra
                - Start with 10-15 minutes and gradually increase
                - Avoid high-impact activities and heavy lifting for at least 3 months
                
                Remember that recovery takes time. Focus on restoring function before working on fitness.
                """,
                type: .article,
                category: .physical,
                readTimeMinutes: 6,
                author: "Singapore Sports Medicine Centre",
                source: "Singapore Sports Institute",
                datePublished: dateFormatter.date(from: "2023-01-20")!,
                isFeatured: false
            ),
            
            Resource(
                id: 7,
                title: "How to Cope with Postpartum Depression",
                description: "Practical strategies for managing postpartum depression while caring for your baby.",
                content: """
                ## How to Cope with Postpartum Depression
                
                Postpartum depression (PPD) is a serious but treatable condition. With the right support and strategies, you can manage your symptoms and enjoy motherhood.
                
                ### Self-Care Strategies
                
                #### Rest When Possible
                - Sleep when your baby sleeps
                - Ask partner or family to take night feeds occasionally
                - Keep your bedroom comfortable and conducive to sleep
                
                #### Nutrition
                - Eat regular, nutritious meals
                - Stay hydrated
                - Consider foods rich in omega-3 fatty acids
                - Limit caffeine and sugar
                
                #### Physical Activity
                - Take short walks with your baby
                - Try gentle postpartum exercises
                - Aim for 10-15 minutes of movement daily
                
                #### Time for Yourself
                - Take short breaks during the day
                - Pursue simple activities you enjoy
                - Practice mindfulness or meditation
                - Use relaxation techniques
                
                ### Building Support
                
                #### Partner Support
                - Communicate your feelings openly
                - Be specific about what help you need
                - Schedule regular check-ins
                
                #### Family and Friends
                - Accept offers of help
                - Create a list of specific tasks others can do
                - Stay connected, even if you don't feel like socializing
                
                #### Professional Support
                - Attend all postpartum check-ups
                - Be honest with healthcare providers about your feelings
                - Consider joining a support group
                
                ### Treatment Options
                
                #### Therapy
                - Cognitive Behavioral Therapy (CBT)
                - Interpersonal Therapy (IPT)
                - Group therapy
                
                #### Medication
                - Antidepressants can be effective for PPD
                - Some are compatible with breastfeeding
                - Always take as prescribed
                
                ### Managing Day-to-Day
                
                - Break tasks into small, manageable steps
                - Celebrate small accomplishments
                - Lower expectations about housework
                - Connect with other mothers
                - Avoid making major life decisions
                
                ### When to Seek Immediate Help
                
                Contact your healthcare provider right away if you:
                - Have thoughts of harming yourself or your baby
                - Feel disconnected from reality
                - Are unable to care for yourself or your baby
                
                Remember, having PPD doesn't make you a bad mother. Seeking help shows your strength and commitment to your family.
                """,
                type: .article,
                category: .mental,
                readTimeMinutes: 5,
                author: "Singapore Mental Health Association",
                source: "IMH Women's Mental Wellness Service",
                datePublished: dateFormatter.date(from: "2023-07-05")!,
                isFeatured: true
            ),
            
            Resource(
                id: 8,
                title: "Gentle Exercises for Postpartum Recovery",
                description: "Video demonstration of safe exercises to help regain strength after childbirth.",
                content: "This video demonstrates a series of gentle exercises specifically designed for postpartum recovery. The exercises focus on rebuilding core strength, improving posture, and strengthening the pelvic floor. Each movement is demonstrated with proper form and modifications for different fitness levels.",
                type: .video,
                category: .physical,
                readTimeMinutes: 12,
                author: "Singapore Physiotherapy Association",
                source: "Singapore Sports Medicine Centre",
                datePublished: dateFormatter.date(from: "2023-04-10")!,
                isFeatured: false
            ),
            
            Resource(
                id: 9,
                title: "Understanding Baby Sleep Patterns",
                description: "Learn about normal infant sleep development and strategies for better sleep.",
                content: """
                ## Understanding Baby Sleep Patterns
                
                Sleep is essential for your baby's development, but it can be one of the most challenging aspects of early parenthood. Understanding how babies sleep can help you set realistic expectations.
                
                ### Newborn Sleep (0-3 months)
                
                #### Sleep Patterns
                - Sleep 14-17 hours per day
                - No established day/night cycle initially
                - Sleep in short bursts of 2-4 hours
                - Spend about half their sleep in REM (active) sleep
                - Make noises, twitch, and move during REM sleep
                
                #### Sleep Tips
                - Focus on creating a safe sleep environment
                - Learn to recognize early tired signs
                - Don't expect consistent patterns yet
                - Help baby distinguish day from night
                - Consider swaddling (until baby shows signs of rolling)
                
                ### Infant Sleep (3-6 months)
                
                #### Sleep Patterns
                - Begin to develop circadian rhythms
                - May sleep 12-15 hours per day
                - Longer stretches at night (3-6 hours)
                - 3-4 naps per day, gradually reducing
                
                #### Sleep Tips
                - Introduce a simple bedtime routine
                - Put baby down drowsy but awake when possible
                - Consider a consistent wake time
                - Watch for overtiredness
                
                ### Older Baby Sleep (6-12 months)
                
                #### Sleep Patterns
                - Sleep 12-14 hours per day
                - May sleep 6+ hours at night
                - Usually 2-3 naps per day
                - Separation anxiety may affect sleep
                
                #### Sleep Tips
                - Maintain consistent bedtime routine
                - Consider gentle sleep training methods
                - Establish regular nap schedule
                - Create consistent sleep associations
                
                ### Safe Sleep Guidelines
                
                - Always place baby on back to sleep
                - Use a firm mattress with fitted sheet
                - Keep crib free of pillows, blankets, and toys
                - Consider room-sharing (not bed-sharing) for first 6-12 months
                - Maintain comfortable room temperature (18-22°C)
                - Avoid overheating
                
                ### When to Seek Help
                
                Consult your pediatrician if:
                - Baby has difficulty breathing during sleep
                - Snores loudly or pauses in breathing
                - Has trouble staying asleep beyond expected norms
                - Shows signs of excessive daytime sleepiness
                
                Remember that all babies are different. What works for one may not work for another. Be patient with your baby and yourself as you navigate this challenging aspect of parenting.
                """,
                type: .article,
                category: .baby,
                readTimeMinutes: 7,
                author: "KK Women's and Children's Hospital",
                source: "KK Hospital Department of Paediatrics",
                datePublished: dateFormatter.date(from: "2023-05-28")!,
                isFeatured: false
            ),
            
            Resource(
                id: 10,
                title: "Postpartum Support Resources in Singapore",
                description: "A comprehensive list of support services available for new mothers in Singapore.",
                content: """
                ## Postpartum Support Resources in Singapore
                
                There are many resources available in Singapore to support new mothers. This guide will help you find the right support for your needs.
                
                ### Medical Support
                
                #### Postnatal Services at Public Hospitals
                - KK Women's and Children's Hospital: 6294 4050
                  - Offers postnatal care, breastfeeding support, and mental health services
                - National University Hospital: 6779 5555
                  - Provides comprehensive postnatal care and parent craft services
                - Singapore General Hospital: 6222 3322
                  - Women's health services include postnatal care and counseling
                
                #### Polyclinics
                - Provide postnatal check-ups and infant developmental assessments
                - Offer immunization services for babies
                - Visit https://www.nhgp.com.sg (National Healthcare Group) or https://www.singhealth.com.sg (SingHealth) for locations
                
                #### Community Health Services
                - Home nursing services
                - Confinement nanny services
                - Lactation consultants
                
                ### Mental Health Support
                
                #### Professional Services
                - KK Hospital Women's Mental Wellness Service: 6394 2200
                - Singapore Association for Mental Health: 1800 283 7019
                - Institute of Mental Health: 6389 2222 (24-hour hotline)
                
                #### Support Groups
                - Postnatal Depression Support Group (PNDSG): https://www.pndsg.org
                - Mindful Mums: https://mindfulmums.sg
                - Mothers of Singapore: https://mothersofsingapore.com
                
                ### Breastfeeding Support
                
                - Breastfeeding Mothers' Support Group: https://breastfeeding.org.sg
                - KK Hospital Breastfeeding Helpline: 6394 1090
                - Joyful Parenting & Breastfeeding Clinic: 6488 0286
                - La Leche League Singapore: https://www.facebook.com/lllsingapore
                
                ### Parenting Support
                
                #### Government Programs
                - Families for Life: https://familiesforlife.sg
                - Baby Bonus Scheme: https://www.babybonus.msf.gov.sg
                - Child Development Centers
                
                #### Community Services
                - Family Service Centers
                - Early Childhood Development Agency: https://www.ecda.gov.sg
                - Parent Support Groups in schools and neighborhoods
                
                ### Financial Assistance
                
                - ComCare: https://www.msf.gov.sg/comcare
                - MediSave for Pregnancy and Delivery
                - Child Development Account (CDA)
                - Working Mother's Child Relief
                
                ### Online Resources
                
                - HealthHub: https://www.healthhub.sg
                - Baby Bonus Parenting Resources: https://www.babybonus.msf.gov.sg
                - ParentLink: https://www.facebook.com/ParentingwithYou
                
                Remember that seeking help is a sign of strength. Reach out to these resources whenever you need support on your parenting journey.
                """,
                type: .article,
                category: .support,
                readTimeMinutes: 5,
                author: "Ministry of Social and Family Development",
                source: "MSF Singapore",
                datePublished: dateFormatter.date(from: "2023-07-12")!,
                isFeatured: false
            ),
            
            Resource(
                id: 11,
                title: "Mindfulness Techniques for New Mothers",
                description: "Simple mindfulness practices to reduce stress and increase well-being during the postpartum period.",
                content: "This video guides new mothers through simple mindfulness practices that can be incorporated into daily routines. It includes breathing exercises, brief meditations, and mindful moments that can be practiced while feeding, changing, or soothing a baby. The techniques focus on reducing stress, increasing present-moment awareness, and cultivating self-compassion.",
                type: .video,
                category: .mental,
                readTimeMinutes: 8,
                author: "Singapore Mental Health Association",
                source: "Mindful Singapore",
                datePublished: dateFormatter.date(from: "2023-02-15")!,
                isFeatured: true
            ),
            
            Resource(
                id: 12,
                title: "Partners in Postpartum: Supporting Your Wife",
                description: "How partners can provide meaningful support during the challenging postpartum period.",
                content: """
                ## Partners in Postpartum: Supporting Your Wife
                
                The postpartum period is challenging for new mothers, both physically and emotionally. As a partner, your support during this time is invaluable. This guide offers practical ways to help.
                
                ### Understanding the Postpartum Experience
                
                #### Physical Recovery
                - Childbirth is physically traumatic, regardless of delivery method
                - Recovery takes weeks to months, not days
                - Physical symptoms include bleeding, soreness, fatigue, and hormonal changes
                
                #### Emotional Changes
                - Baby blues affect up to 80% of mothers
                - Hormonal fluctuations impact mood
                - Sleep deprivation affects emotional regulation
                - Identity shifts can be disorienting
                
                ### Practical Support
                
                #### Household Management
                - Take over household responsibilities
                - Ensure regular meals and snacks
                - Keep track of essential supplies
                - Manage visitors and protect family time
                
                #### Baby Care
                - Learn baby care skills alongside your partner
                - Take shifts for night feedings (bottle feeding) or bring baby to mother and handle diaper changes
                - Become proficient at soothing techniques
                - Schedule pediatrician appointments
                
                #### Physical Support
                - Create opportunities for your partner to rest
                - Encourage her to nap when possible
                - Ensure she stays hydrated, especially if breastfeeding
                - Help with comfortable positioning for breastfeeding
                
                ### Emotional Support
                
                #### Communication
                - Check in regularly about feelings and concerns
                - Practice active listening without offering solutions
                - Validate her experience
                - Express appreciation and admiration
                
                #### Mental Health Awareness
                - Learn the signs of postpartum depression and anxiety
                - Encourage professional help if needed
                - Attend doctor appointments if possible
                - Reassure her that seeking help shows strength
                
                #### Nurturing Your Relationship
                - Create brief moments of connection
                - Adjust expectations about intimacy
                - Find new ways to show affection
                - Remember you're both learning together
                
                ### Taking Care of Yourself
                
                - Maintain your own support network
                - Schedule short breaks for self-care
                - Manage your expectations about this temporary phase
                - Consider joining a fathers' group
                
                ### When to Seek Help
                
                Encourage professional support if your partner:
                - Seems persistently sad or overwhelmed
                - Expresses concerns about harming herself or the baby
                - Shows dramatic personality changes
                - Has difficulty bonding with the baby
                
                Your involvement, patience, and support during this time will help create a strong foundation for your growing family.
                """,
                type: .article,
                category: .support,
                readTimeMinutes: 6,
                author: "Centre for Fathering Singapore",
                source: "Dads for Life Singapore",
                datePublished: dateFormatter.date(from: "2023-03-25")!,
                isFeatured: false
            ),
            
            Resource(
                id: 13,
                title: "Postpartum Nutrition Guide",
                description: "Essential nutritional advice for recovery, energy, and breastfeeding success.",
                content: """
                ## Postpartum Nutrition Guide
                
                Proper nutrition during the postpartum period is essential for your recovery, energy levels, and breastfeeding success. This guide will help you make good food choices during this demanding time.
                
                ### Recovery Nutrition
                
                #### Protein
                - Aids tissue repair and healing
                - Recommended: 71g daily for breastfeeding mothers
                - Sources: Lean meats, poultry, fish, eggs, dairy, legumes, tofu
                
                #### Iron
                - Helps replace blood lost during delivery
                - Particularly important after significant blood loss
                - Sources: Red meat, spinach, beans, fortified cereals
                - Consume with vitamin C for better absorption
                
                #### Calcium
                - Maintains bone health while breastfeeding
                - Recommended: 1000mg daily
                - Sources: Dairy products, fortified plant milks, tofu, leafy greens
                
                ### Energy and Wellness
                
                #### Complex Carbohydrates
                - Provide sustained energy
                - Important for milk production
                - Sources: Whole grains, brown rice, oats, sweet potatoes
                
                #### Healthy Fats
                - Support hormone production
                - Boost absorption of fat-soluble vitamins
                - Sources: Avocados, nuts, seeds, olive oil, fatty fish
                
                #### Fluids
                - Essential for milk production and preventing constipation
                - Aim for 3+ liters daily if breastfeeding
                - Sources: Water, milk, herbal teas, soups
                
                ### Breastfeeding Nutrition
                
                #### Increased Caloric Needs
                - Breastfeeding requires about 500 extra calories daily
                - Focus on nutrient-dense foods, not empty calories
                
                #### Omega-3 Fatty Acids
                - Support baby's brain development
                - Sources: Fatty fish, walnuts, flaxseeds, chia seeds
                
                #### Vitamin D
                - Both mother and baby need adequate vitamin D
                - Sources: Sunlight, fatty fish, fortified foods
                - Supplementation often recommended
                
                ### Practical Tips
                
                #### Meal Preparation
                - Accept offered meals from friends and family
                - Prepare and freeze meals before delivery
                - Focus on one-handed foods for eating while feeding baby
                
                #### Smart Snacking
                - Keep nutritious snacks accessible
                - Ideas: Greek yogurt, cut vegetables with hummus, fruit with nut butter, boiled eggs
                
                #### Cultural Considerations
                - Many cultures have traditional postpartum foods
                - Common Asian practices include warming foods and special soups
                - Consider incorporating these traditions if they appeal to you
                
                ### Foods to Limit
                
                - Alcohol (passes into breast milk)
                - Caffeine (moderate amounts usually fine)
                - Highly processed foods (low in nutrients)
                - Excessive sugar (can affect energy levels)
                
                Remember that good nutrition supports your recovery and wellbeing, but perfection isn't necessary. Do the best you can with the resources available to you.
                """,
                type: .article,
                category: .physical,
                readTimeMinutes: 7,
                author: "Singapore Nutrition and Dietetics Association",
                source: "Health Promotion Board Singapore",
                datePublished: dateFormatter.date(from: "2023-06-02")!,
                isFeatured: false
            ),
            
            Resource(
                id: 14,
                title: "Bonding with Your Baby",
                description: "Simple activities to promote attachment and development in the first months.",
                content: "This video demonstrates simple ways parents can bond with their newborns and promote healthy development. It covers skin-to-skin contact, infant massage, responsive caregiving, talking and singing to baby, and reading together. The video explains how these interactions support brain development and secure attachment, while also honoring the unique relationship between each parent and child.",
                type: .video,
                category: .parenting,
                readTimeMinutes: 10,
                author: "KK Women's and Children's Hospital",
                source: "Department of Child Development, KKH",
                datePublished: dateFormatter.date(from: "2023-04-18")!,
                isFeatured: true
            ),
            
            Resource(
                id: 15,
                title: "Postpartum Medical Check-ups: What to Expect",
                description: "An overview of recommended postpartum check-ups and what they typically include.",
                content: """
                ## Postpartum Medical Check-ups: What to Expect
                
                Postpartum medical check-ups are essential for monitoring your recovery after childbirth. This guide outlines what to expect and why these appointments are important.
                
                ### First Week Check-up
                
                #### Timing
                - Usually 3-5 days after discharge from hospital
                - Earlier for complicated deliveries
                
                #### What's Checked
                - Vital signs
                - Bleeding (lochia)
                - Incision site (for C-section or episiotomy)
                - Breastfeeding progress
                - Baby's weight and jaundice level
                
                #### Common Concerns Addressed
                - Breastfeeding challenges
                - Pain management
                - Signs of infection
                - Baby care questions
                
                ### Six-Week Postpartum Check-up
                
                #### Physical Examination
                - Pelvic exam to check healing
                - Abdominal check for uterine involution
                - Perineum/C-section scar assessment
                - Breast examination
                - Weight and blood pressure
                
                #### Discussions
                - Contraception options
                - Resuming physical activity
                - Resuming sexual activity
                - Any continuing symptoms
                - Return to work planning
                
                #### Screening
                - Postpartum depression screening
                - Blood tests if indicated (anemia, thyroid function)
                - Pap smear if due
                
                ### Three-Month Check-up
                
                Not routinely scheduled but recommended for:
                - Women with complications during delivery
                - Those experiencing ongoing physical problems
                - Those with postpartum depression or anxiety
                
                ### Important Topics to Discuss
                
                #### Physical Recovery
                - Persistent pain
                - Abnormal bleeding
                - Incontinence issues
                - Breastfeeding problems
                
                #### Emotional Health
                - Mood changes
                - Anxiety
                - Sleep difficulties
                - Relationship stress
                
                #### Practical Concerns
                - Return to work
                - Childcare arrangements
                - Family planning
                
                ### Preparing for Your Appointments
                
                #### Keep Track Of
                - Questions and concerns (write them down)
                - Symptoms you've experienced
                - Changes in bleeding patterns
                - Baby feeding and weight gain
                
                #### What to Bring
                - Health records
                - Insurance information
                - List of current medications
                - Your baby (for combined check-ups)
                - Partner or support person
                
                Remember that no concern is too small to discuss with your healthcare provider. These check-ups are an opportunity to address any issues and ensure both you and your baby are thriving.
                """,
                type: .article,
                category: .medical,
                readTimeMinutes: 5,
                author: "Singapore Medical Association",
                source: "Singapore O&G",
                datePublished: dateFormatter.date(from: "2023-05-05")!,
                isFeatured: false
            )
        ]
        
        return singaporeResources
    }
}