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
      const validatedData = insertAssessmentSchema.parse({
        ...req.body,
        userId
      });
      
      const assessment = await storage.createAssessment(validatedData);
      
      // Generate a care plan if one doesn't exist
      const existingPlan = await storage.getLatestCarePlanByUserId(userId);
      if (!existingPlan) {
        // Create default care plan based on assessment score
        const defaultPlan = generateDefaultCarePlan(validatedData.score);
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
    const assessments = await storage.getAssessmentsByUserId(userId);
    res.json(assessments);
  });

  app.get("/api/assessments/latest", requireAuth, async (req, res) => {
    const userId = req.user?.id;
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
    const moods = await storage.getMoodsByUserId(userId);
    res.json(moods);
  });

  app.get("/api/moods/today", requireAuth, async (req, res) => {
    const userId = req.user?.id;
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

  // Resources endpoint (static data for now)
  app.get("/api/resources", requireAuth, async (req, res) => {
    const resources = getResourcesData();
    res.json(resources);
  });

  const httpServer = createServer(app);
  return httpServer;
}

// Default care plan generator based on assessment score
function generateDefaultCarePlan(score: number) {
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

  // Adjust plan based on severity (score)
  if (score > 15) {
    // More severe - add professional recommendations
    defaultPlan.supportAndConnection.push({
      title: "Professional therapy",
      description: "Weekly sessions with a mental health professional",
      type: "support",
    });
  }

  return defaultPlan;
}

// Resources data
function getResourcesData() {
  return {
    categories: [
      { id: "all", name: "All Resources" },
      { id: "basics", name: "PPD Basics" },
      { id: "selfcare", name: "Self-Care" },
      { id: "sleep", name: "Sleep Tips" },
      { id: "relationships", name: "Relationships" }
    ],
    resources: [
      {
        id: 1,
        title: "Understanding the Baby Blues vs. Postpartum Depression",
        description: "Learn the key differences between normal post-birth mood changes and signs of PPD.",
        category: "basics",
        readTime: 8,
        type: "article",
        featured: true
      },
      {
        id: 2,
        title: "5-Minute Mindfulness Exercises for New Moms",
        description: "Quick meditation practices that fit into your busy schedule.",
        category: "selfcare",
        readTime: 3,
        type: "article"
      },
      {
        id: 3,
        title: "Communicating Your Needs to Your Partner",
        description: "How to have productive conversations about postpartum support.",
        category: "relationships",
        readTime: 6,
        type: "article"
      },
      {
        id: 4,
        title: "Sleep Strategies When Caring for a Newborn",
        description: "Expert tips for maximizing sleep during this challenging time.",
        category: "sleep",
        readTime: 12,
        type: "video"
      },
      {
        id: 5,
        title: "Signs You Should Talk to a Professional",
        description: "When and how to reach out for additional mental health support.",
        category: "basics",
        readTime: 5,
        type: "article"
      },
      {
        id: 6,
        title: "Creating a Self-Care Routine That Works",
        description: "Practical tips for finding time for yourself without feeling guilty.",
        category: "selfcare",
        readTime: 7,
        type: "article"
      }
    ]
  };
}
