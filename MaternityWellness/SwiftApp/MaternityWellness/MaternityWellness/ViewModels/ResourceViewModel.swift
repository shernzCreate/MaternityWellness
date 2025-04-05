import SwiftUI
import Combine

class ResourceViewModel: ObservableObject {
    @Published var resources: [Resource] = []
    @Published var featuredResources: [Resource] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var selectedCategory: ResourceCategory?
    
    init() {
        loadResources()
    }
    
    func loadResources() {
        isLoading = true
        
        // Simulate API/database call
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            
            // This would typically come from a backend API
            // For demo purposes, we're creating sample data
            self.resources = self.getSampleResources()
            self.featuredResources = self.resources.filter { $0.isFeatured }
            self.isLoading = false
        }
    }
    
    func getFilteredResources() -> [Resource] {
        guard let category = selectedCategory else {
            return resources
        }
        
        return resources.filter { $0.category == category }
    }
    
    func getSampleResources() -> [Resource] {
        return [
            // Mental Health Resources
            Resource(
                title: "Understanding Postpartum Depression",
                description: "Learn about the symptoms, causes, and treatments for postpartum depression.",
                content: """
                Postpartum depression (PPD) is a serious mental health condition that affects many women after childbirth. Unlike the "baby blues," which involve mild mood swings, sadness, and fatigue that typically resolve within two weeks after delivery, PPD is a more severe, long-lasting form of depression.
                
                Symptoms of PPD can include:
                - Severe mood swings
                - Excessive crying
                - Difficulty bonding with your baby
                - Withdrawing from family and friends
                - Loss of appetite or eating much more than usual
                - Inability to sleep (insomnia) or sleeping too much
                - Overwhelming fatigue or loss of energy
                - Reduced interest and pleasure in activities you used to enjoy
                - Intense irritability and anger
                - Fear that you're not a good mother
                - Hopelessness
                - Feelings of worthlessness, shame, guilt or inadequacy
                - Diminished ability to think clearly, concentrate or make decisions
                - Restlessness
                - Severe anxiety and panic attacks
                - Thoughts of harming yourself or your baby
                - Recurrent thoughts of death or suicide
                
                If you're experiencing any of these symptoms, it's important to seek help from a healthcare professional. Treatment options include therapy, medication, and support groups.
                """,
                category: .mentalHealth,
                type: .article,
                source: "KK Women's and Children's Hospital",
                url: URL(string: "https://www.kkh.com.sg/"),
                readTime: 8,
                isFeatured: true
            ),
            
            // Singapore-specific Resource
            Resource(
                title: "Singapore Postpartum Support Services",
                description: "A comprehensive guide to postpartum support services available in Singapore.",
                content: """
                Singapore offers various support services for mothers experiencing postpartum depression:
                
                **Medical Support:**
                1. **KK Women's and Children's Hospital (KKH)** - Offers specialized care for women with postpartum depression through their Women's Mental Wellness Service.
                   Contact: 6294 4050
                
                2. **National University Hospital (NUH)** - Provides psychological support through their Women's Emotional Health Service.
                   Contact: 6779 5555
                
                3. **Singapore General Hospital (SGH)** - Offers psychiatric services for new mothers.
                   Contact: 6222 3322
                
                **Community Support Groups:**
                1. **Postnatal Depression Support Group** - Run by KKH, this group helps mothers connect with others experiencing similar challenges.
                
                2. **Mother & Child** - Provides counseling and support for new mothers.
                   Website: motherandchild.com.sg
                
                3. **Singapore Psychological Society** - Offers resources and referrals to psychologists specializing in maternal mental health.
                
                **Helplines:**
                1. **National Care Hotline**: 1800-202-6868
                
                2. **Mental Health Helpline**: 6389 2222 (24 hours)
                
                3. **Samaritans of Singapore (SOS)**: 1800-221-4444 (24 hours)
                
                Remember, seeking help is a sign of strength, not weakness. These resources are available to support you through this challenging time.
                """,
                category: .localSupport,
                type: .contact,
                source: "Ministry of Health Singapore",
                url: URL(string: "https://www.moh.gov.sg/"),
                readTime: 5,
                isFeatured: true
            ),
            
            // Physical Health Resource
            Resource(
                title: "Postpartum Recovery Exercises",
                description: "Safe and effective exercises to help your body recover after childbirth.",
                content: """
                # Postpartum Recovery Exercises
                
                These gentle exercises can help restore strength and stability to your core and pelvic floor muscles after childbirth. Always consult with your doctor before beginning any exercise program after giving birth.
                
                ## Deep Breathing with Pelvic Floor Engagement
                1. Sit comfortably or lie on your back with knees bent
                2. Take a deep breath in, allowing your belly to expand
                3. As you exhale, gently contract your pelvic floor muscles (as if stopping the flow of urine)
                4. Hold for 5 seconds, then release
                5. Repeat 10 times, 3 times per day
                
                ## Gentle Core Activation
                1. Lie on your back with knees bent, feet flat on the floor
                2. Place your hands on your lower abdomen
                3. Take a deep breath in
                4. As you exhale, gently draw your belly button toward your spine
                5. Hold for 5 seconds while breathing normally
                6. Release and repeat 10 times
                
                ## Wall Lean
                1. Stand facing a wall, about arm's length away
                2. Place your hands on the wall at shoulder height
                3. Inhale deeply
                4. As you exhale, engage your core and lean toward the wall, bending your elbows
                5. Push back to the starting position
                6. Repeat 10 times
                
                ## Pelvic Tilts
                1. Lie on your back with knees bent, feet flat on the floor
                2. Inhale deeply
                3. As you exhale, tilt your pelvis upward by flattening your lower back against the floor
                4. Hold for 5 seconds
                5. Release and repeat 10 times
                
                Remember to:
                - Stop any exercise that causes pain
                - Wait until any bleeding has stopped before beginning exercise
                - Start slowly and gradually increase intensity
                - Stay hydrated, especially if breastfeeding
                """,
                category: .physicalHealth,
                type: .exercise,
                source: "KK Women's and Children's Hospital",
                url: URL(string: "https://www.kkh.com.sg/patient-care/conditions-treatments/post-delivery-exercise"),
                readTime: 10,
                isFeatured: false
            ),
            
            // Infant Care Resource
            Resource(
                title: "Understanding Your Baby's Cues",
                description: "Learn to recognize and respond to your baby's communication signals.",
                content: """
                # Understanding Your Baby's Cues
                
                Babies communicate their needs through various cues before they start crying. Learning to recognize these early signals can help you respond to your baby's needs promptly and strengthen your bond.
                
                ## Hunger Cues
                
                **Early signs:**
                - Rooting (turning head and opening mouth)
                - Putting hands to mouth
                - Lip smacking
                - Sucking motions or sounds
                
                **Mid signs:**
                - Stretching
                - Increasing physical movement
                - Hand clenching
                
                **Late signs:**
                - Crying
                - Agitated body movements
                - Color turning red
                
                ## Sleepiness Cues
                
                **Early signs:**
                - Decreased activity
                - Less focused gaze
                - Yawning
                - Slower motions
                
                **Mid signs:**
                - Rubbing eyes
                - Fussiness
                - Pulling ears
                
                **Late signs:**
                - Crying
                - Arching backwards
                - Becoming inconsolable
                
                ## Overstimulation Cues
                
                - Looking away or avoiding eye contact
                - Stiffening of the body
                - Splaying fingers or toes
                - Hiccupping or sneezing
                - Fast breathing
                - Raising hands as if to say "stop"
                
                ## Engagement Cues
                
                - Making eye contact
                - Smooth body movements
                - Relaxed hands and face
                - Reaching toward you
                - Cooing or babbling
                
                Learning to read these cues takes time and practice. Be patient with yourself and your baby as you learn this new language together.
                """,
                category: .infantCare,
                type: .article,
                source: "National University Hospital",
                url: URL(string: "https://www.nuh.com.sg/"),
                readTime: 7,
                isFeatured: false
            ),
            
            // Self Care Resource
            Resource(
                title: "Mindfulness for New Mothers",
                description: "Simple mindfulness practices to help you stay present and calm during the postpartum period.",
                content: """
                # Mindfulness for New Mothers
                
                Mindfulness can be a powerful tool for managing stress and enhancing well-being during the postpartum period. These simple practices can be integrated into your daily routine, even with limited time.
                
                ## 1-Minute Breathing Exercise
                
                Try this whenever you feel overwhelmed:
                
                1. Set a timer for 1 minute
                2. Close your eyes if possible (or soften your gaze)
                3. Breathe naturally and focus on the sensation of air entering and leaving your body
                4. When your mind wanders, gently bring your attention back to your breath
                5. After the minute ends, notice how you feel
                
                ## Mindful Daily Activities
                
                Transform routine tasks into mindfulness practices:
                
                **Mindful Feeding:**
                - Whether breast or bottle feeding, fully focus on the experience
                - Notice the weight of your baby, their expressions, the sounds they make
                - Observe your breathing and any sensations in your body
                
                **Mindful Showering:**
                - Pay attention to the sensation of water on your skin
                - Notice the temperature, pressure, and sound of the water
                - When thoughts arise, acknowledge them and return to the sensory experience
                
                **Mindful Walking:**
                - When walking with or without your baby, pay attention to each step
                - Feel your foot making contact with the ground
                - Notice the movement of your body and the air on your skin
                
                ## 3-Minute Body Scan
                
                Try this when lying down to rest:
                
                1. Starting at your head, bring awareness to each part of your body
                2. Notice any sensations without judgment
                3. Acknowledge areas of tension and imagine breathing into them
                4. Continue down to your toes
                5. Finish with awareness of your body as a whole
                
                Remember that mindfulness is not about achieving a particular state but about being present with whatever is happening. Be gentle with yourself as you practice.
                """,
                category: .selfCare,
                type: .exercise,
                source: "Singapore Mental Health Association",
                url: URL(string: "https://www.samhealth.org.sg/"),
                readTime: 5,
                isFeatured: true
            ),
            
            // Family Support Resource
            Resource(
                title: "How Partners Can Support New Mothers",
                description: "Practical ways partners can provide support during the postpartum period.",
                content: """
                # How Partners Can Support New Mothers
                
                The support of a partner can significantly impact a mother's postpartum experience. Here are practical ways to provide meaningful help:
                
                ## Emotional Support
                
                - **Listen actively:** Sometimes listening without trying to solve problems is what's needed most.
                
                - **Validate feelings:** Acknowledge that her feelings are real and important, even if they seem irrational or intense.
                
                - **Watch for warning signs:** Be alert to symptoms of postpartum depression and anxiety, and encourage professional help when needed.
                
                - **Express appreciation:** Specifically acknowledge her efforts and strengths as a mother.
                
                ## Practical Support
                
                - **Share night duties:** Even if breastfeeding, partners can handle diaper changes, bringing the baby to mom, and putting baby back to sleep.
                
                - **Take on household responsibilities:** Cooking, cleaning, shopping, and other chores can be overwhelming for a recovering mother.
                
                - **Manage visitors:** Act as gatekeeper to ensure mom gets adequate rest and isn't overwhelmed by well-meaning visitors.
                
                - **Ensure self-care time:** Encourage and facilitate time for the mother to shower, nap, exercise, or simply have some alone time.
                
                ## Communication Tips
                
                - Check in regularly about how she's feeling
                - Ask specific questions rather than "What can I do to help?"
                - Discuss expectations and adjust as needed
                - Remember that both partners are adjusting to new roles
                
                ## Taking Care of Yourself
                
                Supporting a new mother is challenging. Remember to:
                
                - Find ways to rest and recharge
                - Seek your own support network
                - Be patient with yourself and your partner
                - Communicate your own needs clearly
                
                By taking care of yourself, you'll be better equipped to provide the support your partner needs during this transformative time.
                """,
                category: .familySupport,
                type: .article,
                source: "National University Hospital",
                url: URL(string: "https://www.nuh.com.sg/"),
                readTime: 6,
                isFeatured: false
            ),
            
            // Video Resource
            Resource(
                title: "Gentle Postpartum Yoga",
                description: "A 15-minute yoga routine designed specifically for postpartum recovery.",
                content: "This video demonstrates gentle yoga poses that can help with physical recovery after childbirth. The routine focuses on rebuilding core strength, relieving back pain, and promoting relaxation.",
                category: .physicalHealth,
                type: .video,
                source: "KK Women's and Children's Hospital",
                url: URL(string: "https://www.youtube.com/watch?v=example"),
                readTime: 15,
                isFeatured: false
            ),
            
            // Additional Singapore Resource
            Resource(
                title: "Financial Support for New Parents in Singapore",
                description: "Information about government benefits and financial assistance available to new parents in Singapore.",
                content: """
                # Financial Support for New Parents in Singapore
                
                The Singapore government offers several benefits and schemes to help ease the financial burden for new parents:
                
                ## Baby Bonus Scheme
                
                The Baby Bonus Scheme consists of:
                
                1. **Cash Gift:**
                   - First and second child: S$8,000
                   - Third and subsequent children: S$10,000
                   
                2. **Child Development Account (CDA):**
                   - Government matches your savings dollar-for-dollar up to:
                     - First and second child: S$6,000
                     - Third and fourth child: S$12,000
                     - Fifth and subsequent children: S$18,000
                
                ## Medisave Grant for Newborns
                
                Each newborn receives a S$4,000 Medisave grant deposited into their CPF Medisave account, which can be used for healthcare expenses.
                
                ## Government-Paid Leave Schemes
                
                1. **Maternity Leave:**
                   - 16 weeks of government-paid maternity leave for working mothers
                   
                2. **Paternity Leave:**
                   - 2 weeks of government-paid paternity leave
                   
                3. **Shared Parental Leave:**
                   - Fathers can share up to 4 weeks of the mother's 16-week maternity leave
                   
                4. **Childcare Leave:**
                   - 6 days per year for each parent with children under age 7
                   - 2 days per year for each parent with children aged 7-12
                
                ## Subsidy for Infant Care and Childcare
                
                Subsidies for infant care and childcare programs at eligible centers:
                
                - **Basic Subsidy:**
                  - Infant care (2-18 months): Up to S$600 monthly
                  - Childcare (18 months-7 years): Up to S$300 monthly
                  
                - **Additional Subsidy:**
                  - For lower and middle-income families
                  - Up to S$710 monthly for infant care
                  - Up to S$467 monthly for childcare
                
                ## How to Apply
                
                Most benefits are automatically processed when you register your child's birth. For specific schemes:
                
                1. **Baby Bonus:** Apply online via the Baby Bonus Online portal
                2. **Leave Schemes:** Apply through your employer
                3. **Childcare Subsidies:** Apply through your chosen childcare center
                
                For more information, visit the MSF website (www.msf.gov.sg) or the Baby Bonus website (www.babybonus.msf.gov.sg).
                """,
                category: .localSupport,
                type: .article,
                source: "Ministry of Social and Family Development",
                url: URL(string: "https://www.msf.gov.sg/"),
                readTime: 8,
                isFeatured: false
            )
        ]
    }
}