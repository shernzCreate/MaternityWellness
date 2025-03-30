import type { Express } from "express";
import { createServer, type Server } from "http";
import { storage } from "./storage";
import { setupAuth } from "./auth";
import { z } from "zod";
import {
  insertAssessmentSchema,
  insertMoodSchema,
  insertCarePlanSchema,
  insertGoalSchema
} from "@shared/schema";

export async function registerRoutes(app: Express): Promise<Server> {
  // Setup authentication routes
  setupAuth(app);

  // Middleware to check if user is authenticated
  const requireAuth = (req: any, res: any, next: any) => {
    if (!req.isAuthenticated()) {
      return res.status(401).json({ message: "Unauthorized" });
    }
    next();
  };

  // Assessment routes
  app.post("/api/assessments", requireAuth, async (req, res) => {
    try {
      const userId = req.user?.id;
      if (userId === undefined) {
        return res.status(401).json({ message: "User ID not found" });
      }
      
      const validatedData = insertAssessmentSchema.parse({
        ...req.body,
        userId
      });
      
      const assessment = await storage.createAssessment(validatedData);
      
      // Generate a care plan if one doesn't exist
      const existingPlan = await storage.getLatestCarePlanByUserId(userId);
      if (!existingPlan) {
        // Create default care plan based on assessment score and type
        const defaultPlan = generateDefaultCarePlan(validatedData.score, validatedData.type);
        await storage.createCarePlan({
          userId,
          plan: defaultPlan
        });
      }
      
      res.status(201).json(assessment);
    } catch (error) {
      res.status(400).json({ message: "Invalid assessment data", error });
    }
  });

  app.get("/api/assessments", requireAuth, async (req, res) => {
    const userId = req.user?.id;
    if (userId === undefined) {
      return res.status(401).json({ message: "User ID not found" });
    }
    const assessments = await storage.getAssessmentsByUserId(userId);
    res.json(assessments);
  });

  app.get("/api/assessments/history", requireAuth, async (req, res) => {
    const userId = req.user?.id;
    if (userId === undefined) {
      return res.status(401).json({ message: "User ID not found" });
    }
    const assessments = await storage.getAssessmentsByUserId(userId);
    
    // Sort assessments by date (newest first)
    const sortedAssessments = assessments.sort((a, b) => {
      const dateA = new Date(b.date || new Date());
      const dateB = new Date(a.date || new Date());
      return dateA.getTime() - dateB.getTime();
    });
    
    res.json(sortedAssessments);
  });

  app.get("/api/assessments/latest", requireAuth, async (req, res) => {
    const userId = req.user?.id;
    if (userId === undefined) {
      return res.status(401).json({ message: "User ID not found" });
    }
    const assessment = await storage.getLatestAssessmentByUserId(userId);
    if (!assessment) {
      return res.status(404).json({ message: "No assessments found" });
    }
    res.json(assessment);
  });

  // Mood tracking routes
  app.post("/api/moods", requireAuth, async (req, res) => {
    try {
      const userId = req.user?.id;
      if (userId === undefined) {
        return res.status(401).json({ message: "User ID not found" });
      }
      
      const validatedData = insertMoodSchema.parse({
        ...req.body,
        userId
      });
      
      const mood = await storage.createMood(validatedData);
      res.status(201).json(mood);
    } catch (error) {
      res.status(400).json({ message: "Invalid mood data", error });
    }
  });

  app.get("/api/moods", requireAuth, async (req, res) => {
    const userId = req.user?.id;
    if (userId === undefined) {
      return res.status(401).json({ message: "User ID not found" });
    }
    const moods = await storage.getMoodsByUserId(userId);
    res.json(moods);
  });

  app.get("/api/moods/today", requireAuth, async (req, res) => {
    const userId = req.user?.id;
    if (userId === undefined) {
      return res.status(401).json({ message: "User ID not found" });
    }
    const mood = await storage.getTodaysMood(userId);
    if (!mood) {
      return res.status(404).json({ message: "No mood tracked today" });
    }
    res.json(mood);
  });

  // Care plan routes
  app.post("/api/care-plans", requireAuth, async (req, res) => {
    try {
      const userId = req.user?.id;
      if (userId === undefined) {
        return res.status(401).json({ message: "User ID not found" });
      }
      
      const validatedData = insertCarePlanSchema.parse({
        ...req.body,
        userId
      });
      
      const carePlan = await storage.createCarePlan(validatedData);
      res.status(201).json(carePlan);
    } catch (error) {
      res.status(400).json({ message: "Invalid care plan data", error });
    }
  });

  app.get("/api/care-plans/latest", requireAuth, async (req, res) => {
    const userId = req.user?.id;
    if (userId === undefined) {
      return res.status(401).json({ message: "User ID not found" });
    }
    const carePlan = await storage.getLatestCarePlanByUserId(userId);
    if (!carePlan) {
      return res.status(404).json({ message: "No care plan found" });
    }
    res.json(carePlan);
  });

  // Goals routes
  app.post("/api/goals", requireAuth, async (req, res) => {
    try {
      const userId = req.user?.id;
      if (userId === undefined) {
        return res.status(401).json({ message: "User ID not found" });
      }
      
      const validatedData = insertGoalSchema.parse({
        ...req.body,
        userId
      });
      
      const goal = await storage.createGoal(validatedData);
      res.status(201).json(goal);
    } catch (error) {
      res.status(400).json({ message: "Invalid goal data", error });
    }
  });

  app.get("/api/goals", requireAuth, async (req, res) => {
    const userId = req.user?.id;
    if (userId === undefined) {
      return res.status(401).json({ message: "User ID not found" });
    }
    const goals = await storage.getGoalsByUserId(userId);
    res.json(goals);
  });

  app.patch("/api/goals/:id", requireAuth, async (req, res) => {
    try {
      const goalId = parseInt(req.params.id);
      const { completed } = req.body;
      
      if (typeof completed !== 'boolean') {
        return res.status(400).json({ message: "Invalid completion status" });
      }
      
      const goal = await storage.updateGoalCompletion(goalId, completed);
      if (!goal) {
        return res.status(404).json({ message: "Goal not found" });
      }
      
      res.json(goal);
    } catch (error) {
      res.status(400).json({ message: "Error updating goal", error });
    }
  });

  // Resources endpoints
  app.get("/api/resources", requireAuth, async (req, res) => {
    const resources = getResourcesData();
    res.json(resources);
  });
  
  // Bookmarks endpoint
  app.get("/api/resources/bookmarks", requireAuth, async (req, res) => {
    const userId = req.user?.id;
    if (userId === undefined) {
      return res.status(401).json({ message: "User ID not found" });
    }
    
    // For demo purposes, let's assume some bookmarked resources
    const bookmarks = [
      { userId, resourceId: 5 },
      { userId, resourceId: 8 }
    ];
    
    res.json({ bookmarks });
  });
  
  // Toggle bookmark status
  app.post("/api/resources/bookmark", requireAuth, async (req, res) => {
    const userId = req.user?.id;
    if (userId === undefined) {
      return res.status(401).json({ message: "User ID not found" });
    }
    
    const { resourceId, bookmarked } = req.body;
    if (resourceId === undefined) {
      return res.status(400).json({ message: "Resource ID is required" });
    }
    
    // In a real application, we would update the database
    // For now, just return success
    res.json({ success: true, resourceId, bookmarked });
  });
  
  // Resource progress endpoint
  app.get("/api/resources/progress", requireAuth, async (req, res) => {
    const userId = req.user?.id;
    if (userId === undefined) {
      return res.status(401).json({ message: "User ID not found" });
    }
    
    // For demo purposes, let's assume some resource progress
    const progress = [
      { 
        userId, 
        resourceId: 1, 
        progress: 75, 
        completed: false, 
        lastViewed: new Date().toISOString() 
      },
      { 
        userId, 
        resourceId: 4, 
        progress: 100, 
        completed: true, 
        lastViewed: new Date().toISOString() 
      },
      { 
        userId, 
        resourceId: 5, 
        progress: 30, 
        completed: false, 
        lastViewed: new Date().toISOString() 
      }
    ];
    
    res.json({ progress });
  });
  
  // Record resource view
  app.post("/api/resources/viewed", requireAuth, async (req, res) => {
    const userId = req.user?.id;
    if (userId === undefined) {
      return res.status(401).json({ message: "User ID not found" });
    }
    
    const { resourceId } = req.body;
    if (resourceId === undefined) {
      return res.status(400).json({ message: "Resource ID is required" });
    }
    
    // In a real application, we would update the database
    // For now, just return success
    res.json({ success: true });
  });
  
  // Mark resource as completed
  app.post("/api/resources/completed", requireAuth, async (req, res) => {
    const userId = req.user?.id;
    if (userId === undefined) {
      return res.status(401).json({ message: "User ID not found" });
    }
    
    const { resourceId } = req.body;
    if (resourceId === undefined) {
      return res.status(400).json({ message: "Resource ID is required" });
    }
    
    // In a real application, we would update the database
    // For now, just return success
    res.json({ success: true });
  });

  const httpServer = createServer(app);
  return httpServer;
}

// Default care plan generator based on assessment score and type
function generateDefaultCarePlan(score: number, type: string = 'epds') {
  const defaultPlan = {
    mindAndEmotions: [
      {
        title: "Daily mindfulness practice",
        description: "5-10 minutes guided meditation",
        type: "mind",
      },
      {
        title: "Thought journal",
        description: "Track mood changes and identify triggers",
        type: "mind",
      }
    ],
    bodyAndRest: [
      {
        title: "Sleep optimization",
        description: "Strategies to improve sleep quality",
        type: "body",
      },
      {
        title: "Gentle movement",
        description: "Postpartum-safe physical activities",
        type: "body",
      }
    ],
    supportAndConnection: [
      {
        title: "Weekly support group",
        description: "Virtual meetup with other mothers",
        type: "support",
      },
      {
        title: "Communication templates",
        description: "Scripts for asking for help from loved ones",
        type: "support",
      }
    ],
    goals: [
      {
        title: "Take a 15-minute walk outside",
        description: "Fresh air and movement to boost mood",
      },
      {
        title: "Practice deep breathing for 5 minutes",
        description: "Helps reduce anxiety and stress hormones",
      },
      {
        title: "Connect with a friend or family member",
        description: "Social support is crucial for mental health",
      }
    ]
  };

  // Adjust plan based on assessment type and severity
  if (type === 'epds') {
    // EPDS scoring thresholds
    if (score > 13) {
      // Probable depression - add professional recommendations
      defaultPlan.supportAndConnection.push({
        title: "Professional therapy",
        description: "Weekly sessions with a maternal mental health specialist",
        type: "support",
      });
      
      defaultPlan.mindAndEmotions.push({
        title: "Structured self-care plan",
        description: "Daily scheduled activities to boost maternal wellbeing",
        type: "mind",
      });
    } else if (score > 9) {
      // Possible depression - add self-monitoring
      defaultPlan.mindAndEmotions.push({
        title: "Mood monitoring",
        description: "Track daily emotions to identify patterns and triggers",
        type: "mind",
      });
    }
  } else if (type === 'phq9') {
    // PHQ-9 scoring thresholds
    if (score >= 20) {
      // Severe depression
      defaultPlan.supportAndConnection.push({
        title: "Urgent mental health support",
        description: "Connect with a mental health professional as soon as possible",
        type: "support",
      });
      
      defaultPlan.mindAndEmotions.push({
        title: "Crisis response plan",
        description: "Steps to follow when feeling overwhelmed or in crisis",
        type: "mind",
      });
    } else if (score >= 15) {
      // Moderately severe depression
      defaultPlan.supportAndConnection.push({
        title: "Professional therapy",
        description: "Regular sessions with a mental health professional",
        type: "support",
      });
      
      defaultPlan.bodyAndRest.push({
        title: "Regular physical activity",
        description: "30 minutes of moderate exercise most days of the week",
        type: "body",
      });
    } else if (score >= 10) {
      // Moderate depression
      defaultPlan.mindAndEmotions.push({
        title: "Structured daily routine",
        description: "Planning daily activities to maintain regular schedule",
        type: "mind",
      });
    }
  }

  return defaultPlan;
}

// Resources data
function getResourcesData() {
  return {
    categories: [
      { id: "all", name: "All Resources" },
      { id: "singapore", name: "Singapore Resources" },
      { id: "basics", name: "PPD Basics" },
      { id: "selfcare", name: "Self-Care" },
      { id: "exercise", name: "Exercise & Movement" },
      { id: "family", name: "Family Impact" },
      { id: "sleep", name: "Sleep Tips" },
      { id: "relationships", name: "Relationships" },
      { id: "support", name: "Local Support" }
    ],
    resources: [
      {
        id: 1,
        title: "Understanding the Baby Blues vs. Postpartum Depression",
        description: "Learn the key differences between normal post-birth mood changes and signs of PPD.",
        category: "basics",
        readTime: 8,
        type: "article",
        featured: true,
        content: `<h2>Understanding Postpartum Depression vs. Baby Blues</h2>
        <p>Many new mothers experience the "baby blues" after childbirth, which commonly include mood swings, crying spells, anxiety, and difficulty sleeping. Baby blues typically begin within the first two to three days after delivery, and may last for up to two weeks.</p>
        <p>But some new moms experience a more severe, long-lasting form of depression known as postpartum depression. Approximately 1 in 7 women experience PPD after giving birth.</p>
        <p>Signs and symptoms of baby blues — which last only a few days to a week or two after your baby is born — may include:</p>
        <ul>
          <li>Mood swings</li>
          <li>Anxiety</li>
          <li>Sadness</li>
          <li>Irritability</li>
          <li>Feeling overwhelmed</li>
          <li>Crying</li>
          <li>Reduced concentration</li>
          <li>Appetite problems</li>
          <li>Trouble sleeping</li>
        </ul>
        <p>Postpartum depression may be mistaken for baby blues at first — but the signs and symptoms are more intense and last longer, and may eventually interfere with your ability to care for your baby and handle other daily tasks. Symptoms usually develop within the first few weeks after giving birth, but may begin earlier ― during pregnancy ― or later — up to a year after birth.</p>
        <p>If you're experiencing postpartum depression, you may feel hopeless and worthless or even have thoughts of harming yourself or your baby. If you are having these feelings, it's important to seek help immediately from your doctor or a mental health professional.</p>`,
        tags: ["mental health", "postpartum", "education"]
      },
      {
        id: 2,
        title: "5-Minute Mindfulness Exercises for New Moms",
        description: "Quick meditation practices that fit into your busy schedule.",
        category: "selfcare",
        readTime: 3,
        type: "article",
        content: `<h2>5-Minute Mindfulness Exercises for New Moms</h2>
        <p>Finding time for self-care with a newborn can seem impossible, but even brief moments of mindfulness can help reduce stress and increase your sense of calm.</p>
        <p>Here are five mindfulness exercises you can do in 5 minutes or less:</p>
        <h3>1. Mindful Breathing During Feeding</h3>
        <p>Whether you're breastfeeding or bottle feeding, this is a perfect time to practice mindfulness:</p>
        <ul>
          <li>As your baby feeds, bring your attention to your breath</li>
          <li>Notice the sensation of breathing in and out</li>
          <li>When your mind wanders (which it will!), gently bring your focus back to your breath</li>
          <li>Try counting your breaths if that helps you stay focused</li>
        </ul>
        <h3>2. Body Scan While Baby Naps</h3>
        <p>When your baby is sleeping, take a moment to check in with your body:</p>
        <ul>
          <li>Sitting or lying down, close your eyes and bring awareness to different parts of your body</li>
          <li>Start at your toes and work your way up to the top of your head</li>
          <li>Notice any tension or discomfort without judgment</li>
          <li>Breathe into any areas of tension, imagining them softening</li>
        </ul>
        <h3>3. Mindful Shower</h3>
        <p>Turn your shower into a mindful retreat:</p>
        <ul>
          <li>Focus on the sensations of water on your skin</li>
          <li>Notice the temperature, pressure, and sound of the water</li>
          <li>Be aware of the scent of soap or shampoo</li>
          <li>When your mind starts planning or worrying, gently return to these sensations</li>
        </ul>
        <h3>4. One-Minute Gratitude Practice</h3>
        <p>Even in challenging times, finding moments of gratitude can shift your perspective:</p>
        <ul>
          <li>Set a timer for one minute</li>
          <li>Close your eyes and think of three things you're grateful for today</li>
          <li>They can be simple things: a warm cup of tea, a smile from your baby, or support from a partner or friend</li>
          <li>Focus on how these things make you feel</li>
        </ul>
        <h3>5. Grounding Exercise During Overwhelm</h3>
        <p>When emotions feel intense, try this quick grounding technique:</p>
        <ul>
          <li>Notice 5 things you can see</li>
          <li>Acknowledge 4 things you can touch</li>
          <li>Be aware of 3 things you can hear</li>
          <li>Notice 2 things you can smell (or like to smell)</li>
          <li>Acknowledge 1 thing you can taste</li>
        </ul>
        <p>Remember, mindfulness isn't about achieving perfect focus or eliminating all stress. It's about bringing gentle awareness to the present moment, which can provide brief respite during the challenging early days of motherhood.</p>`,
        tags: ["mindfulness", "mental health", "self-care"]
      },
      {
        id: 3,
        title: "How Postpartum Depression Affects Your Family",
        description: "Understanding the impact of PPD on your relationship with your partner and baby.",
        category: "family",
        readTime: 8,
        type: "article",
        content: `<h2>How Postpartum Depression Affects Your Family</h2>
        <p>Postpartum depression (PPD) doesn't just affect the mother – it can impact the entire family system. Understanding these effects can help families seek appropriate support and develop strategies to strengthen bonds during this challenging time.</p>
        
        <h3>Impact on Mother-Infant Bonding</h3>
        <p>Research has shown that PPD can affect how mothers interact with their babies:</p>
        <ul>
          <li>Mothers with PPD may find it more difficult to respond sensitively to their baby's cues</li>
          <li>They may have trouble experiencing joy during interactions with their infant</li>
          <li>Some mothers report feeling disconnected or detached from their baby</li>
          <li>Women with PPD may experience more negative perceptions of their infant's behavior</li>
        </ul>
        <p>However, with proper treatment and support, these effects can be mitigated, and the mother-infant relationship can be strengthened.</p>
        
        <h3>Effects on Partners</h3>
        <p>Partners of women with PPD often experience significant challenges:</p>
        <ul>
          <li>Increased responsibility for infant care and household tasks</li>
          <li>Feelings of helplessness in not knowing how to support their partner</li>
          <li>Higher rates of depression themselves (up to 50% of partners of women with PPD may develop depression)</li>
          <li>Strain on the couple's relationship and communication</li>
          <li>Confusion about what is happening and how to help</li>
        </ul>
        
        <h3>Long-term Impact on Children</h3>
        <p>Untreated maternal depression can have long-term effects on children's development:</p>
        <ul>
          <li>Children may be at higher risk for emotional and behavioral problems</li>
          <li>Cognitive development, including language acquisition, may be affected</li>
          <li>Some studies show potential impacts on school readiness and academic performance</li>
          <li>Children may develop less secure attachment patterns</li>
        </ul>
        <p>Importantly, when mothers receive effective treatment for PPD, many of these effects can be prevented or reversed.</p>
        
        <h3>Breaking the Cycle: Why Treatment Matters</h3>
        <p>Seeking help for PPD isn't just important for the mother's wellbeing – it benefits the entire family:</p>
        <ul>
          <li>Effective treatment helps restore sensitive parenting and positive interactions</li>
          <li>Partners experience relief when appropriate support systems are in place</li>
          <li>Children show resilience when maternal depression improves</li>
          <li>Family relationships can be strengthened through the recovery process</li>
        </ul>
        
        <h3>How Partners Can Help</h3>
        <p>Partners can play a crucial role in supporting recovery:</p>
        <ul>
          <li>Learn about PPD symptoms and treatment options</li>
          <li>Encourage and facilitate professional help-seeking</li>
          <li>Take on additional parenting and household responsibilities</li>
          <li>Ensure the mother gets breaks and opportunities for self-care</li>
          <li>Provide emotional support without judgment</li>
          <li>Seek support for themselves through friends, family, or counseling</li>
        </ul>
        
        <p>Remember that PPD is a medical condition, not a weakness or failure. With proper support and treatment, families can navigate this challenging time and emerge with strengthened relationships.</p>`,
        tags: ["family", "relationships", "children", "education"]
      },
      {
        id: 4,
        title: "Gentle Postpartum Exercises: Singapore Physiotherapist Guide",
        description: "KK Women's and Children's Hospital approved exercises that are safe for new mothers.",
        category: "exercise",
        readTime: 12,
        type: "video",
        publishDate: "2023-04-15",
        author: "KK Women's and Children's Hospital",
        content: `<h2>Gentle Postpartum Exercises: Singapore Physiotherapist Guide</h2>
        <div class="video-container">
          <p>Video content showing gentle exercises recommended by KK Women's and Children's Hospital physiotherapists.</p>
          <p>These exercises include pelvic floor strengthening, gentle abdominal reconnection, and posture improvement techniques that are safe for postpartum women.</p>
        </div>
        
        <h3>When to Start Exercising After Birth</h3>
        <p>Always consult with your doctor before beginning any exercise program. Generally:</p>
        <ul>
          <li>After vaginal delivery: You may begin gentle exercises like pelvic floor exercises within days after giving birth</li>
          <li>After cesarean delivery: Wait until your post-operative check-up (usually 6 weeks)</li>
        </ul>
        
        <h3>Recommended Exercises</h3>
        <ol>
          <li><strong>Pelvic Floor Exercises (Kegels)</strong>
            <ul>
              <li>Identify your pelvic floor muscles by stopping urination midstream</li>
              <li>Tighten these muscles, hold for 5 seconds, then release for 5 seconds</li>
              <li>Repeat 10 times, 3 times daily</li>
              <li>Gradually increase to holding for 10 seconds</li>
            </ul>
          </li>
          <li><strong>Gentle Abdominal Breathing</strong>
            <ul>
              <li>Lie on your back with knees bent, feet flat on the floor</li>
              <li>Place hands on your abdomen</li>
              <li>Breathe in deeply through your nose, feeling your abdomen rise</li>
              <li>Exhale slowly through your mouth, gently engaging your abdominal muscles</li>
              <li>Repeat 10 times</li>
            </ul>
          </li>
          <li><strong>Pelvic Tilts</strong>
            <ul>
              <li>Lie on your back with knees bent, feet flat on the floor</li>
              <li>Flatten your back against the floor by tightening your abdominal muscles and tilting your pelvis</li>
              <li>Hold for 5 seconds, then release</li>
              <li>Repeat 10 times</li>
            </ul>
          </li>
          <li><strong>Shoulder Rolls</strong>
            <ul>
              <li>Sit upright in a comfortable position</li>
              <li>Roll your shoulders forward in a circular motion 5 times</li>
              <li>Roll your shoulders backward in a circular motion 5 times</li>
              <li>This helps relieve tension from holding and feeding your baby</li>
            </ul>
          </li>
          <li><strong>Wall Push-ups</strong>
            <ul>
              <li>Stand facing a wall, arms-length away</li>
              <li>Place your palms flat against the wall at shoulder height</li>
              <li>Bend your elbows to bring your body toward the wall</li>
              <li>Push back to the starting position</li>
              <li>Repeat 10 times</li>
            </ul>
          </li>
        </ol>
        
        <h3>Warning Signs to Stop Exercising</h3>
        <p>Stop exercising and contact your healthcare provider if you experience:</p>
        <ul>
          <li>Increased vaginal bleeding</li>
          <li>Severe pain</li>
          <li>Dizziness or lightheadedness</li>
          <li>Shortness of breath</li>
          <li>Chest pain</li>
          <li>Headache</li>
          <li>Muscle weakness</li>
          <li>Calf pain or swelling</li>
        </ul>
        
        <p>Remember that recovery takes time. Be patient with yourself and start slowly, gradually increasing the intensity of your exercises as you build strength.</p>`,
        sourceUrl: "https://www.kkh.com.sg/patient-care/areas-of-care/womens-services",
        tags: ["singapore", "exercise", "postpartum", "physical health", "KKH"]
      },
      {
        id: 5,
        title: "When to Seek Professional Help - Singapore Mental Health Resources",
        description: "Guidance on recognizing concerning symptoms and where to find help in Singapore.",
        category: "singapore",
        readTime: 5,
        type: "article",
        publishDate: "2023-06-10",
        author: "Ministry of Health, Singapore",
        content: `<h2>When to Seek Professional Help for Postpartum Depression in Singapore</h2>
        
        <p>Postpartum depression is a serious condition that affects approximately 10-15% of women in Singapore. Recognizing when to seek professional help is crucial for your wellbeing and your family's health.</p>
        
        <h3>Warning Signs That Require Professional Attention</h3>
        <p>Seek help if you experience any of these symptoms for more than two weeks:</p>
        <ul>
          <li>Persistent feelings of sadness, emptiness, or hopelessness</li>
          <li>Loss of interest in activities you once enjoyed</li>
          <li>Extreme fatigue or energy loss beyond normal new parent tiredness</li>
          <li>Significant anxiety, worry, or panic attacks</li>
          <li>Overwhelming feelings of guilt or worthlessness as a mother</li>
          <li>Difficulty bonding with your baby</li>
          <li>Withdrawal from family and friends</li>
          <li>Changes in appetite or sleep patterns (beyond normal new parent adjustments)</li>
          <li>Recurrent thoughts of death or suicide</li>
          <li>Thoughts of harming yourself or your baby</li>
        </ul>
        
        <p><strong>If you have thoughts of harming yourself or your baby, seek help immediately by going to any hospital's Emergency Department or call 995.</strong></p>
        
        <h3>Where to Find Help in Singapore</h3>
        
        <h4>KK Women's and Children's Hospital (KKH)</h4>
        <p>KKH offers specialized mental health services for women, including those experiencing postpartum depression.</p>
        <ul>
          <li>Women's Mental Wellness Service: 6294 4050</li>
          <li>Location: 100 Bukit Timah Road, Singapore 229899</li>
          <li>Website: <a href="https://www.kkh.com.sg">www.kkh.com.sg</a></li>
        </ul>
        
        <h4>National University Hospital (NUH)</h4>
        <p>NUH provides comprehensive mental health services, including support for new mothers.</p>
        <ul>
          <li>Appointment Hotline: 6772 2002</li>
          <li>Location: 5 Lower Kent Ridge Road, Singapore 119074</li>
          <li>Website: <a href="https://www.nuh.com.sg">www.nuh.com.sg</a></li>
        </ul>
        
        <h4>Singapore General Hospital (SGH)</h4>
        <p>SGH offers psychiatric services that can provide assessment and treatment for postpartum depression.</p>
        <ul>
          <li>Appointment Hotline: 6321 4377</li>
          <li>Location: Outram Road, Singapore 169608</li>
          <li>Website: <a href="https://www.sgh.com.sg">www.sgh.com.sg</a></li>
        </ul>
        
        <h4>Postnatal Depression Support Group</h4>
        <p>This support group is organized by KKH and provides a safe space for mothers experiencing postpartum depression to share their experiences and gain support.</p>
        <ul>
          <li>Contact: 6394 2200</li>
        </ul>
        
        <h4>Association of Women for Action and Research (AWARE)</h4>
        <p>AWARE provides counseling services and can refer you to appropriate mental health resources.</p>
        <ul>
          <li>Helpline: 1800 777 5555</li>
          <li>Website: <a href="https://www.aware.org.sg">www.aware.org.sg</a></li>
        </ul>
        
        <h4>Singapore Association for Mental Health (SAMH)</h4>
        <p>SAMH offers counseling and support services for various mental health issues, including postpartum depression.</p>
        <ul>
          <li>Helpline: 1800 283 7019</li>
          <li>Website: <a href="https://www.samhealth.org.sg">www.samhealth.org.sg</a></li>
        </ul>
        
        <h4>National Care Hotline</h4>
        <p>For immediate emotional support:</p>
        <ul>
          <li>Hotline: 1800 202 6868</li>
          <li>Operating hours: 8am to 12am daily</li>
        </ul>
        
        <h3>What to Expect When Seeking Help</h3>
        <p>When you reach out for professional help, you can expect:</p>
        <ol>
          <li>An initial assessment to understand your symptoms and concerns</li>
          <li>Discussion of treatment options, which may include counseling, psychotherapy, and/or medication</li>
          <li>Development of a personalized care plan</li>
          <li>Regular follow-up appointments to monitor your progress</li>
          <li>Referrals to additional resources if needed</li>
        </ol>
        
        <p>Remember, seeking help is a sign of strength, not weakness. With appropriate treatment, most women with postpartum depression recover completely.</p>`,
        sourceUrl: "https://www.healthhub.sg/",
        tags: ["singapore", "mental health", "resources", "support", "MOH"]
      },
      {
        id: 6,
        title: "Coping with Postpartum Depression - Practical Strategies",
        description: "Singapore psychiatrists share evidence-based approaches to managing PPD symptoms.",
        category: "basics",
        readTime: 7,
        type: "article",
        publishDate: "2023-08-22",
        author: "National University Hospital, Singapore",
        content: `<h2>Coping with Postpartum Depression - Practical Strategies</h2>
        
        <p>Postpartum depression (PPD) can make the already challenging adjustment to parenthood even more difficult. These evidence-based strategies, recommended by psychiatrists at National University Hospital Singapore, can help you manage symptoms while you seek professional treatment.</p>
        
        <h3>Daily Management Strategies</h3>
        
        <h4>1. Prioritize Basic Self-Care</h4>
        <ul>
          <li><strong>Sleep:</strong> Sleep when your baby sleeps, even during the day. Ask your partner or a trusted family member to handle one night feeding so you can get a longer stretch of sleep.</li>
          <li><strong>Nutrition:</strong> Eat regular, nutritious meals. Keep healthy, easy-to-eat snacks readily available.</li>
          <li><strong>Hydration:</strong> Drink plenty of water, especially if you're breastfeeding.</li>
          <li><strong>Movement:</strong> Even gentle physical activity like a short walk can boost mood-enhancing chemicals in your brain.</li>
        </ul>
        
        <h4>2. Set Realistic Expectations</h4>
        <ul>
          <li>Let go of the idea of being a "perfect" parent – it doesn't exist.</li>
          <li>Focus on essential tasks and let non-essential housework slide.</li>
          <li>Remember that every baby and mother pair is unique – avoid comparing yourself to others.</li>
        </ul>
        
        <h4>3. Connect with Others</h4>
        <ul>
          <li>Share your feelings with a trusted friend or family member.</li>
          <li>Join a support group for new mothers or specifically for postpartum depression.</li>
          <li>Consider online communities if in-person connection is difficult.</li>
        </ul>
        
        <h4>4. Accept and Ask for Help</h4>
        <ul>
          <li>Make a list of specific tasks others can do (meals, laundry, baby care, etc.).</li>
          <li>When someone offers help, accept it and refer to your list.</li>
          <li>Consider hiring help if possible, even temporarily.</li>
        </ul>
        
        <h3>Emotional Coping Techniques</h3>
        
        <h4>1. Challenge Negative Thoughts</h4>
        <p>When you notice a negative thought (e.g., "I'm a terrible mother"), ask yourself:</p>
        <ul>
          <li>Is this thought based on facts or feelings?</li>
          <li>What would I say to a friend in my situation?</li>
          <li>What's a more balanced way to view this situation?</li>
        </ul>
        
        <h4>2. Practice Mindfulness</h4>
        <ul>
          <li>Focus on the present moment rather than worrying about the future or ruminating on the past.</li>
          <li>Notice your thoughts and feelings without judgment.</li>
          <li>Use simple breathing exercises when feeling overwhelmed.</li>
        </ul>
        
        <h4>3. Scheduled Positive Activities</h4>
        <ul>
          <li>Plan small, achievable activities that brought you joy before pregnancy.</li>
          <li>Schedule these activities into your week, even if brief.</li>
          <li>Notice and acknowledge positive moments with your baby.</li>
        </ul>
        
        <h3>Practical Tips for Partners and Family Members</h3>
        
        <h4>How to Support a Mother with PPD</h4>
        <ul>
          <li>Listen without judgment or trying to "fix" everything.</li>
          <li>Take on specific household and baby care tasks without being asked.</li>
          <li>Encourage and facilitate professional help.</li>
          <li>Ensure she gets breaks and time for self-care.</li>
          <li>Validate her feelings and reassure her that PPD is not her fault.</li>
          <li>Learn about PPD to better understand what she's experiencing.</li>
          <li>Watch for worsening symptoms and help her access emergency care if needed.</li>
        </ul>
        
        <h3>Remember: Recovery Takes Time</h3>
        <p>PPD recovery isn't linear – there will be better days and harder days. With proper treatment and support, most women fully recover from postpartum depression. Be patient with yourself through this process.</p>
        
        <p><strong>Note:</strong> These coping strategies are meant to complement, not replace, professional treatment. If you're experiencing symptoms of postpartum depression, please seek help from a healthcare provider.</p>`,
        sourceUrl: "https://www.nuh.com.sg",
        tags: ["singapore", "mental health", "coping strategies", "family support", "NUH"]
      },
      {
        id: 7,
        title: "Managing Postpartum Anxiety and Depression: Yoga and Breathing Techniques",
        description: "Gentle movement and breathing exercises specifically designed for new mothers.",
        category: "exercise",
        readTime: 10,
        type: "video",
        publishDate: "2023-03-18",
        content: `<h2>Yoga and Breathing Techniques for Postpartum Mental Wellness</h2>
        <div class="video-container">
          <p>Video content demonstrating gentle yoga poses and breathing techniques that help reduce anxiety and enhance mood.</p>
          <p>The video shows modifications for different postpartum stages and recovery needs.</p>
        </div>
        
        <h3>Benefits of Postpartum Yoga</h3>
        <ul>
          <li>Reduces stress hormones and increases relaxation response</li>
          <li>Gently strengthens core and pelvic floor muscles</li>
          <li>Improves posture and alleviates common physical discomforts</li>
          <li>Creates space for mindfulness and self-compassion</li>
          <li>Can be done in short sessions when baby is napping</li>
        </ul>
        
        <h3>Featured Breathing Techniques</h3>
        
        <h4>1. Diaphragmatic Breathing (Belly Breathing)</h4>
        <p>This fundamental breathing technique helps activate the parasympathetic nervous system, reducing anxiety:</p>
        <ol>
          <li>Sit comfortably or lie on your back with knees bent</li>
          <li>Place one hand on your chest and one on your abdomen</li>
          <li>Inhale slowly through your nose, allowing your abdomen to rise (your chest should remain relatively still)</li>
          <li>Exhale slowly through your mouth, feeling your abdomen fall</li>
          <li>Continue for 5-10 breaths</li>
        </ol>
        
        <h4>2. 4-7-8 Breathing</h4>
        <p>This technique is particularly helpful for reducing racing thoughts and promoting sleep:</p>
        <ol>
          <li>Inhale quietly through your nose for a count of 4</li>
          <li>Hold your breath for a count of 7</li>
          <li>Exhale completely through your mouth for a count of 8</li>
          <li>Repeat for 4 cycles</li>
        </ol>
        
        <h4>3. Alternate Nostril Breathing (Nadi Shodhana)</h4>
        <p>This practice helps balance energy and calm the mind:</p>
        <ol>
          <li>Sit comfortably with your spine straight</li>
          <li>Rest your left hand on your left knee</li>
          <li>With your right hand, fold your index and middle fingers toward your palm</li>
          <li>Close your right nostril with your right thumb</li>
          <li>Inhale slowly through your left nostril</li>
          <li>Close your left nostril with your ring finger, release your thumb</li>
          <li>Exhale slowly through your right nostril</li>
          <li>Inhale through your right nostril</li>
          <li>Close your right nostril, release your ring finger</li>
          <li>Exhale through your left nostril</li>
          <li>This completes one cycle. Repeat for 5-10 cycles</li>
        </ol>
        
        <h3>Gentle Yoga Poses for Postpartum Recovery</h3>
        
        <p>The video demonstrates these poses with modifications. Always listen to your body and consult with your healthcare provider before beginning any exercise program.</p>
        
        <h4>1. Gentle Spinal Twists</h4>
        <p>Helps relieve back tension from carrying and feeding baby</p>
        
        <h4>2. Cat-Cow Pose</h4>
        <p>Gently mobilizes the spine and can help relieve back pain</p>
        
        <h4>3. Bridge Pose (modified)</h4>
        <p>Strengthens the pelvic floor and lower back</p>
        
        <h4>4. Legs Up the Wall</h4>
        <p>A restorative pose that reduces swelling and promotes relaxation</p>
        
        <h4>5. Child's Pose</h4>
        <p>A resting pose that gently stretches the back and hips</p>
        
        <h3>Creating a Sustainable Practice</h3>
        <ul>
          <li>Start with just 5 minutes daily</li>
          <li>Practice when baby is sleeping or content</li>
          <li>Remember that consistency matters more than duration</li>
          <li>Be gentle with yourself – honor where your body is today</li>
          <li>Incorporate breathing techniques into daily activities (like feeding)</li>
        </ul>
        
        <p>Remember, these practices are meant to complement medical treatment for postpartum depression or anxiety, not replace it. Always discuss your symptoms with your healthcare provider.</p>`,
        tags: ["exercise", "yoga", "breathing", "mindfulness", "video"]
      },
      {
        id: 8,
        title: "Singapore's Community Support Networks for New Mothers",
        description: "Local support groups, community resources, and helplines in Singapore.",
        category: "support",
        readTime: 6,
        type: "article",
        publishDate: "2023-07-05",
        author: "HealthHub, Ministry of Health Singapore",
        content: `<h2>Singapore's Community Support Networks for New Mothers</h2>
        
        <p>New motherhood can feel isolating, especially when experiencing postpartum mood challenges. Singapore offers various community resources to help mothers connect with others and access support.</p>
        
        <h3>Parent Support Groups</h3>
        
        <h4>Breastfeeding Mothers' Support Group (Singapore)</h4>
        <ul>
          <li>Offers support for breastfeeding mothers and general maternal wellness</li>
          <li>Runs regular meet-ups across the island</li>
          <li>Provides a helpline: 6339 3558</li>
          <li>Website: <a href="https://breastfeeding.org.sg">breastfeeding.org.sg</a></li>
        </ul>
        
        <h4>Mother & Child Singapore</h4>
        <ul>
          <li>Community support for new mothers</li>
          <li>Regular social gatherings and educational talks</li>
          <li>Website: <a href="https://motherandchild.org.sg">motherandchild.org.sg</a></li>
        </ul>
        
        <h4>ParentLink by KK Women's and Children's Hospital</h4>
        <ul>
          <li>Support group meetings for parents</li>
          <li>Educational sessions on various parenting topics</li>
          <li>Contact: 6394 1980</li>
        </ul>
        
        <h3>Mental Health Support Services</h3>
        
        <h4>Postnatal Depression Support Group (KKH)</h4>
        <ul>
          <li>Facilitated support group specifically for mothers experiencing PPD</li>
          <li>Contact Women's Mental Wellness Service: 6294 4050</li>
        </ul>
        
        <h4>Samaritans of Singapore (SOS)</h4>
        <ul>
          <li>24-hour emotional support for those in crisis</li>
          <li>Hotline: 1-767</li>
          <li>Email: pat@sos.org.sg</li>
          <li>Website: <a href="https://www.sos.org.sg">www.sos.org.sg</a></li>
        </ul>
        
        <h4>Singapore Association for Mental Health (SAMH)</h4>
        <ul>
          <li>Counseling services and support groups</li>
          <li>Helpline: 1800 283 7019</li>
          <li>Website: <a href="https://www.samhealth.org.sg">www.samhealth.org.sg</a></li>
        </ul>
        
        <h3>Online Communities</h3>
        
        <h4>Singapore Mothers Support Group (Facebook)</h4>
        <ul>
          <li>Private Facebook group for mothers to share experiences and seek advice</li>
          <li>Search "Singapore Mothers Support Group" on Facebook to request to join</li>
        </ul>
        
        <h4>Baby Bonus Parenting Group</h4>
        <ul>
          <li>Online forum for parents to discuss parenting matters</li>
          <li>Website: <a href="https://www.babybonus.msf.gov.sg">www.babybonus.msf.gov.sg</a></li>
        </ul>
        
        <h3>Community Centers and Family Service Centers</h3>
        
        <p>Many community centers across Singapore offer parent support programs and activities:</p>
        
        <h4>Family Service Centres (FSCs)</h4>
        <ul>
          <li>Island-wide centers providing counseling and family support services</li>
          <li>Find your nearest FSC: <a href="https://www.msf.gov.sg/dfcs/familyservice/default.aspx">www.msf.gov.sg/dfcs/familyservice</a></li>
        </ul>
        
        <h4>Community Health Assist Scheme (CHAS) Clinics</h4>
        <ul>
          <li>Subsidized medical and mental health services</li>
          <li>Find a CHAS clinic: <a href="https://www.chas.sg">www.chas.sg</a></li>
        </ul>
        
        <h3>Practical Support Services</h3>
        
        <h4>Confinement Nanny Services</h4>
        <ul>
          <li>The tradition of hiring confinement nannies provides practical support during the postnatal period</li>
          <li>Various agencies provide these services throughout Singapore</li>
        </ul>
        
        <h4>Home Help Services</h4>
        <ul>
          <li>NTUC Health: Provides home care services</li>
          <li>Contact: 6715 6715</li>
          <li>Website: <a href="https://ntuchealth.sg">ntuchealth.sg</a></li>
        </ul>
        
        <h3>Cultural and Religious Communities</h3>
        <p>Many religious organizations in Singapore offer mother's groups and family support:</p>
        <ul>
          <li>Check with your local religious organization for specific programs</li>
        </ul>
        
        <h3>Reaching Out</h3>
        <p>Taking the first step to connect can be challenging, especially when experiencing postpartum mood issues. Start small:</p>
        <ul>
          <li>Call a helpline for anonymous support</li>
          <li>Join an online forum before attending in-person events</li>
          <li>Bring a supportive friend or family member to your first group meeting</li>
          <li>Remember that many other mothers are experiencing similar challenges</li>
        </ul>
        
        <p>Building a support network is an important part of maternal mental health. Reach out early and connect with others who understand what you're going through.</p>`,
        sourceUrl: "https://www.healthhub.sg",
        tags: ["singapore", "support", "community", "resources", "MOH"]
      },
      {
        id: 9,
        title: "How Partners Can Support Mothers with Postpartum Depression",
        description: "Practical guidance for spouses and partners on providing effective support.",
        category: "relationships",
        readTime: 9,
        type: "article",
        publishDate: "2023-05-12",
        content: `<h2>How Partners Can Support Mothers with Postpartum Depression</h2>
        
        <p>When your partner is experiencing postpartum depression (PPD), you may feel helpless, confused, or overwhelmed. Your support plays a crucial role in her recovery. This guide offers practical ways to help both of you navigate this challenging time.</p>
        
        <h3>Understanding Postpartum Depression</h3>
        
        <p>First, educate yourself about PPD:</p>
        <ul>
          <li>PPD is a medical condition caused by a combination of physical, emotional, and hormonal factors</li>
          <li>It is not a reflection of your partner's character, parenting abilities, or feelings about the baby</li>
          <li>It is not something she can simply "snap out of" or overcome through willpower</li>
          <li>Recovery typically requires professional treatment, which may include therapy, medication, or both</li>
          <li>With proper support and treatment, most women fully recover from PPD</li>
        </ul>
        
        <h3>Recognizing Your Partner's Experience</h3>
        
        <p>Women with PPD may experience:</p>
        <ul>
          <li>Intense emotional pain and suffering</li>
          <li>Feelings of inadequacy, guilt, or worthlessness as a mother</li>
          <li>Fear that she is irreparably failing her baby or family</li>
          <li>Physical symptoms like fatigue, changes in appetite, and sleep disturbances</li>
          <li>Difficulties with concentration and decision-making</li>
          <li>Overwhelming anxiety or intrusive thoughts</li>
        </ul>
        
        <h3>Practical Ways to Support Her</h3>
        
        <h4>1. Encourage Professional Help</h4>
        <ul>
          <li>Gently suggest speaking with a healthcare provider</li>
          <li>Offer to make appointments and accompany her</li>
          <li>Help her prepare what to say at appointments</li>
          <li>Reassure her that seeking help demonstrates strength and good parenting</li>
          <li>Support treatment plans, including medication if prescribed</li>
        </ul>
        
        <h4>2. Share the Load</h4>
        <ul>
          <li>Take on specific household responsibilities</li>
          <li>Learn and handle baby care tasks (feeding, changing, soothing)</li>
          <li>Take the baby for periods so she can rest or have time to herself</li>
          <li>Handle middle-of-the-night wakings when possible</li>
          <li>Coordinate help from family and friends if needed</li>
        </ul>
        
        <h4>3. Provide Emotional Support</h4>
        <ul>
          <li>Listen without trying to "fix" everything</li>
          <li>Validate her feelings without judgment</li>
          <li>Avoid phrases like "cheer up" or "it's not that bad"</li>
          <li>Reassure her that she is a good mother</li>
          <li>Express specific appreciation for things she does</li>
          <li>Remind her that PPD is temporary and she will feel better</li>
        </ul>
        
        <h4>4. Foster Self-Care</h4>
        <ul>
          <li>Encourage and facilitate basic self-care (sleep, nutrition, exercise)</li>
          <li>Create opportunities for her to do things she enjoys</li>
          <li>Support her connections with friends and family</li>
          <li>Recognize when she's having a particularly difficult day and adjust expectations</li>
        </ul>
        
        <h4>5. Watch for Warning Signs</h4>
        <ul>
          <li>Be alert to worsening symptoms or talk of self-harm</li>
          <li>Know when and how to access emergency mental health services</li>
          <li>Take any expressions of suicidal thoughts seriously</li>
          <li>Don't leave her alone if she expresses thoughts of harming herself or the baby</li>
        </ul>
        
        <h3>Taking Care of Yourself</h3>
        
        <p>Supporting a partner with PPD can be emotionally draining. Your wellbeing matters too:</p>
        <ul>
          <li>Recognize that partners can experience depression too (up to 10% do)</li>
          <li>Maintain some of your own activities and interests</li>
          <li>Seek support from trusted friends or family</li>
          <li>Consider joining a support group for partners of those with PPD</li>
          <li>Take breaks when needed</li>
          <li>Seek professional help for yourself if you're struggling</li>
        </ul>
        
        <h3>Communication Strategies</h3>
        
        <h4>Helpful phrases:</h4>
        <ul>
          <li>"I'm here for you. We'll get through this together."</li>
          <li>"This isn't your fault. It's a medical condition."</li>
          <li>"You're a wonderful mother, even if you don't feel like it right now."</li>
          <li>"Tell me how I can help you today."</li>
          <li>"Your feelings are valid."</li>
          <li>"I'm proud of you for how you're handling this."</li>
        </ul>
        
        <h4>Less helpful phrases to avoid:</h4>
        <ul>
          <li>"You just need to think positively."</li>
          <li>"I don't understand why you're not enjoying this time."</li>
          <li>"Other mothers seem to manage fine."</li>
          <li>"The baby needs you to be happy."</li>
          <li>"Maybe you're just tired."</li>
        </ul>
        
        <h3>Remember:</h3>
        <p>Recovery from PPD takes time. There will be good days and harder days. Your consistent presence and support are powerful factors in her recovery. By facing this together, many couples report that their relationship ultimately grows stronger through the experience.</p>`,
        tags: ["relationships", "partners", "family", "support"]
      },
      {
        id: 10,
        title: "Effect of Maternal Depression on Child Development",
        description: "Research-based information on how maternal mental health impacts children.",
        category: "family",
        readTime: 11,
        type: "article",
        publishDate: "2023-09-20",
        author: "National University Hospital, Singapore",
        content: `<h2>How Maternal Depression Affects Child Development: What Parents Should Know</h2>
        
        <p>Understanding the potential effects of maternal depression on children can be a powerful motivator for seeking treatment. This information is not meant to cause guilt or worry, but rather to highlight why maternal mental health is important for the whole family.</p>
        
        <h3>Research Findings on Child Development</h3>
        
        <p>Research has shown that untreated maternal depression can impact children in several areas:</p>
        
        <h4>Emotional Development</h4>
        <ul>
          <li>Children of mothers with untreated depression may show more difficulty regulating their emotions</li>
          <li>They may be more likely to develop anxiety or depression themselves</li>
          <li>They might display more negative emotions and less positive affect</li>
        </ul>
        
        <h4>Cognitive Development</h4>
        <ul>
          <li>Some studies have found lower cognitive performance scores in children whose mothers experienced prolonged, untreated depression</li>
          <li>Language development may be affected due to reduced verbal interaction</li>
          <li>School readiness skills might develop more slowly</li>
        </ul>
        
        <h4>Social Development</h4>
        <ul>
          <li>Children may develop less secure attachment patterns</li>
          <li>They might show more difficulty in peer relationships</li>
          <li>Social problem-solving skills can be affected</li>
        </ul>
        
        <h4>Behavioral Development</h4>
        <ul>
          <li>Higher rates of behavioral problems have been observed</li>
          <li>Children may show more difficulty with attention and concentration</li>
          <li>They might display more challenging behaviors at home and school</li>
        </ul>
        
        <h3>How Depression Affects Parenting</h3>
        
        <p>Depression can influence parenting behaviors in ways that impact children:</p>
        <ul>
          <li>Reduced responsiveness to infant cues</li>
          <li>Less verbal and nonverbal interaction (talking, singing, facial expressions)</li>
          <li>Difficulty maintaining consistent routines and boundaries</li>
          <li>Less engagement in play and development-promoting activities</li>
          <li>More negative perceptions of normal child behavior</li>
        </ul>
        
        <h3>The Good News: Treatment Makes a Difference</h3>
        
        <p>Research also shows positive outcomes when mothers receive effective treatment:</p>
        <ul>
          <li>As maternal depression improves, many negative effects on children can be reduced or reversed</li>
          <li>When mothers receive appropriate treatment, they typically become more responsive and engaged in parenting</li>
          <li>Even a partial improvement in maternal symptoms is associated with better child outcomes</li>
          <li>Early intervention produces better results for both mother and child</li>
        </ul>
        
        <h3>Building Resilience in Children</h3>
        
        <p>Even during maternal depression, several factors can promote resilience in children:</p>
        <ul>
          <li><strong>Secure attachment to at least one caregiver</strong> - this could be the father, grandparent, or other consistent adult</li>
          <li><strong>Maintaining routines</strong> - predictability helps children feel secure</li>
          <li><strong>Age-appropriate explanations</strong> - for older children, explaining that mom is experiencing an illness can reduce confusion</li>
          <li><strong>Quality over quantity</strong> - even brief periods of positive interaction are beneficial</li>
          <li><strong>Multiple supportive relationships</strong> - connections with extended family, teachers, or other caregivers</li>
        </ul>
        
        <h3>Practical Steps for Parents</h3>
        
        <h4>For Mothers Experiencing Depression:</h4>
        <ul>
          <li>Prioritize getting professional treatment - this is one of the most important things you can do for your child</li>
          <li>Share information about your depression with key caregivers in your child's life</li>
          <li>When you're having a better moment, try to engage in even brief positive interactions with your child</li>
          <li>Consider video recording yourself reading a story or singing during a good moment, which can be played for your child during more difficult times</li>
          <li>Remember that being "good enough" is sufficient - perfection is not required</li>
        </ul>
        
        <h4>For Partners and Co-Parents:</h4>
        <ul>
          <li>Support the mother in getting treatment</li>
          <li>Increase your direct engagement with the child</li>
          <li>Maintain consistent routines and boundaries</li>
          <li>Facilitate positive mother-child interactions when possible</li>
          <li>Help explain the situation to the child in age-appropriate ways</li>
          <li>Arrange for additional supportive adults in the child's life</li>
        </ul>
        
        <h3>A Message of Hope</h3>
        
        <p>While the research on maternal depression and child outcomes is important to understand, remember:</p>
        <ul>
          <li>The relationship between maternal depression and child outcomes is complex and influenced by many factors</li>
          <li>Many children of mothers who experienced depression develop normally without significant issues</li>
          <li>No parent provides perfect care 100% of the time</li>
          <li>Children are resilient and can thrive when supported by even one consistent, caring adult</li>
          <li>By seeking help for depression, you are demonstrating tremendous strength and love for your child</li>
        </ul>
        
        <p>If you're struggling with postpartum depression, reaching out for help is one of the most important gifts you can give to both yourself and your child.</p>`,
        sourceUrl: "https://www.nuh.com.sg",
        tags: ["family", "children", "development", "education", "research", "NUH"]
      },
      {
        id: 11,
        title: "Coping with Postpartum Depression - Video Guide",
        description: "Singapore mental health professionals share strategies for managing PPD symptoms.",
        category: "basics",
        readTime: 15,
        type: "video",
        publishDate: "2023-10-05",
        author: "KK Women's and Children's Hospital",
        content: `<h2>Coping with Postpartum Depression - Video Guide</h2>
        <div class="video-container">
          <p>Video content featuring Singapore mental health professionals discussing coping strategies for postpartum depression.</p>
          <p>The video includes interviews with psychiatrists, psychologists, and women who have recovered from PPD sharing their experiences and advice.</p>
        </div>
        
        <h3>Video Highlights: Expert Advice</h3>
        
        <h4>Understanding the Biology</h4>
        <p>Dr. Chen Wei Ling, Psychiatrist at KKH, explains:</p>
        <blockquote>
          "Postpartum depression involves significant hormonal fluctuations after childbirth. Estrogen and progesterone levels drop dramatically, while the body adjusts to new patterns of prolactin and oxytocin release. These hormonal shifts, combined with sleep deprivation and the enormous adjustment to parenthood, can trigger depression in vulnerable individuals."
        </blockquote>
        
        <h4>Cognitive-Behavioral Strategies</h4>
        <p>Sarah Tan, Clinical Psychologist, discusses:</p>
        <blockquote>
          "We teach mothers to identify and challenge negative thought patterns. For example, when a mother thinks 'I'm a terrible mother because my baby won't stop crying,' we help her reframe this to something more accurate like 'All babies cry, and it doesn't mean I'm failing as a mother. I'm learning and doing my best.'"
        </blockquote>
        
        <h4>Mindfulness Approaches</h4>
        <p>Dr. Lim Boon Leng, Psychiatrist, shares:</p>
        <blockquote>
          "Mindfulness helps mothers observe their thoughts and feelings without judgment. This creates space between the emotion and the response. Even simple practices like focusing on the breath for a few minutes can activate the relaxation response and reduce the intensity of difficult emotions."
        </blockquote>
        
        <h3>Stories of Recovery</h3>
        
        <h4>Mei Ling's Experience</h4>
        <blockquote>
          "I felt completely overwhelmed and guilty that I wasn't enjoying motherhood like I thought I should. I couldn't sleep even when my baby was sleeping, and I worried constantly that something bad would happen. Getting help was the hardest but best decision I made. With medication and therapy, I gradually started to feel like myself again and could finally enjoy being with my daughter."
        </blockquote>
        
        <h4>Priya's Journey</h4>
        <blockquote>
          "I tried to hide my feelings because in my family, we don't talk about mental health issues. But when I started having thoughts about running away, I knew I needed help. My doctor was so understanding. She explained that PPD is common and treatable. Six months of therapy and support group meetings changed everything. To other moms struggling: you are not alone, and it does get better."
        </blockquote>
        
        <h3>Professional Treatment Options</h3>
        
        <p>The video discusses several treatment approaches used in Singapore:</p>
        
        <h4>Psychotherapy</h4>
        <ul>
          <li>Cognitive-Behavioral Therapy (CBT)</li>
          <li>Interpersonal Therapy (IPT)</li>
          <li>Supportive counseling</li>
        </ul>
        
        <h4>Medication</h4>
        <ul>
          <li>Antidepressants that are safe during breastfeeding</li>
          <li>When medication is recommended</li>
          <li>Addressing concerns about medication</li>
        </ul>
        
        <h4>Support Groups</h4>
        <ul>
          <li>Benefits of peer support</li>
          <li>Available groups in Singapore</li>
          <li>What to expect in a support group setting</li>
        </ul>
        
        <h3>When to Seek Help Immediately</h3>
        
        <p>The video emphasizes that certain symptoms require immediate attention:</p>
        <ul>
          <li>Thoughts of harming yourself or your baby</li>
          <li>Hearing voices or seeing things others don't</li>
          <li>Feeling disconnected from reality</li>
          <li>Inability to sleep for several days</li>
          <li>Inability to care for basic needs of yourself or your baby</li>
        </ul>
        
        <h3>Message to Partners and Family</h3>
        
        <p>Dr. Tan Chuan Chong, Psychiatrist, addresses families:</p>
        <blockquote>
          "Family support is crucial in recovery from postpartum depression. Listen without judgment, encourage professional help, and take on practical responsibilities. Remember that your loved one isn't choosing to feel this way - she's experiencing a medical condition that requires treatment and support. With proper care and understanding, recovery is the expected outcome."
        </blockquote>
        
        <h3>Resources in Singapore</h3>
        
        <p>The video concludes with information about resources for postpartum depression in Singapore, including:</p>
        <ul>
          <li>KK Women's and Children's Hospital Women's Mental Wellness Service</li>
          <li>National University Hospital psychiatric services</li>
          <li>Singapore General Hospital's postnatal support programs</li>
          <li>Hotlines and crisis services</li>
          <li>Community support organizations</li>
        </ul>`,
        sourceUrl: "https://www.kkh.com.sg",
        tags: ["singapore", "video", "coping strategies", "mental health", "KKH"]
      },
      {
        id: 12,
        title: "Sleep Strategies for New Mothers in Singapore",
        description: "Cultural approaches to postpartum rest and practical sleep tips for maternal wellbeing.",
        category: "sleep",
        readTime: 7,
        type: "article",
        publishDate: "2023-05-28",
        content: `<h2>Sleep Strategies for New Mothers in Singapore</h2>
        
        <p>Sleep deprivation is one of the most challenging aspects of early parenthood and can significantly worsen postpartum depression symptoms. This guide combines traditional Singapore postpartum practices with modern sleep science to help new mothers maximize rest.</p>
        
        <h3>Understanding Confinement Practices</h3>
        
        <p>Singapore's diverse cultural traditions include various "confinement" practices (坐月子 in Chinese tradition, pantang after childbirth in Malay culture, and tharpanam in Indian tradition). While not all aspects of traditional confinement are medically necessary, the emphasis on maternal rest is valuable:</p>
        
        <ul>
          <li>The traditional 30-40 day postpartum period prioritizes the mother's recovery and rest</li>
          <li>Family members typically take over household responsibilities</li>
          <li>In modern Singapore, many families hire confinement nannies to support new mothers</li>
          <li>This cultural practice recognizes that maternal recuperation is essential for long-term family health</li>
        </ul>
        
        <h3>Modern Sleep Strategies</h3>
        
        <h4>1. Synchronize Sleep When Possible</h4>
        <ul>
          <li>Sleep when your baby sleeps, even during the day</li>
          <li>Avoid the temptation to use baby's nap time for chores</li>
          <li>Even 20-30 minute naps can be restorative</li>
        </ul>
        
        <h4>2. Optimize Your Sleep Environment</h4>
        <ul>
          <li>Keep the room dark (use blackout curtains if needed)</li>
          <li>Maintain a cool, comfortable temperature (24-26°C is ideal in Singapore's climate)</li>
          <li>Use white noise to mask household or neighborhood sounds</li>
          <li>Remove electronic devices or put them on "do not disturb" mode</li>
        </ul>
        
        <h4>3. Share Night Duties</h4>
        <ul>
          <li>If you're formula feeding, take turns with your partner for night feedings</li>
          <li>If you're breastfeeding, have your partner handle diaper changes and settling the baby back to sleep</li>
          <li>Consider having your partner bring the baby to you for night feeds, then taking the baby back after feeding</li>
          <li>If you have a confinement nanny, discuss night support options</li>
        </ul>
        
        <h4>4. Feeding Considerations</h4>
        <ul>
          <li>If breastfeeding, consider side-lying positions that allow you to rest while feeding</li>
          <li>Learn safe co-sleeping practices if you choose this option</li>
          <li>If pumping, consider having someone else give an occasional night feeding with expressed milk</li>
          <li>Limit caffeine, especially after noon</li>
        </ul>
        
        <h4>5. Practical Household Arrangements</h4>
        <ul>
          <li>Set up a changing station in your bedroom to minimize nighttime disruption</li>
          <li>Keep essential items within easy reach of your bed</li>
          <li>Consider sleeping in a separate room from your partner occasionally if their sleep disrupts yours</li>
          <li>If space allows, take turns with your partner sleeping in a "quiet room" for one full night of uninterrupted sleep</li>
        </ul>
        
        <h3>Creating a Sustainable Sleep Plan</h3>
        
        <h4>For Families With Help:</h4>
        <ul>
          <li>Clearly communicate your needs to family members or your confinement nanny</li>
          <li>Create a schedule that includes dedicated sleep blocks for you</li>
          <li>Don't hesitate to adjust the traditional confinement practices to prioritize your rest</li>
          <li>Schedule at least one 3-4 hour uninterrupted sleep period every 24 hours</li>
        </ul>
        
        <h4>For Families Without Help:</h4>
        <ul>
          <li>Simplify your expectations for housework and other responsibilities</li>
          <li>Accept help when offered and be specific about what would be most useful</li>
          <li>Consider pooling resources with friends to hire occasional help</li>
          <li>Explore community resources that might provide postpartum support</li>
        </ul>
        
        <h3>When Sleep Problems May Indicate Depression</h3>
        
        <p>While some sleep disruption is normal with a newborn, certain sleep patterns may indicate postpartum depression:</p>
        <ul>
          <li>Inability to sleep even when your baby is sleeping</li>
          <li>Waking up significantly earlier than necessary and being unable to return to sleep</li>
          <li>Extreme anxiety about sleeping or about what might happen while you sleep</li>
          <li>Persistent nightmares or intrusive thoughts that disrupt sleep</li>
        </ul>
        
        <p>If you're experiencing these symptoms, discussing them with your healthcare provider is important.</p>
        
        <h3>Cultural Wisdom for the Modern Mother</h3>
        
        <p>Singapore's traditional emphasis on maternal rest during the postpartum period contains wisdom that modern research confirms. Don't feel guilty about prioritizing your sleep - it's essential for:</p>
        <ul>
          <li>Your physical recovery from childbirth</li>
          <li>Your emotional wellbeing and mental health</li>
          <li>Your ability to care for and bond with your baby</li>
          <li>Your milk production, if breastfeeding</li>
          <li>Your cognitive function and decision-making</li>
        </ul>
        
        <p>Remember that the postpartum period is temporary. With support and strategic planning, you can manage sleep disruption and protect your wellbeing during this challenging transition.</p>`,
        tags: ["singapore", "sleep", "self-care", "cultural practices"]
      }
    ]
  };
}
