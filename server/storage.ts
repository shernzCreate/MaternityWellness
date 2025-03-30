import { 
  users, type User, type InsertUser,
  assessments, type Assessment, type InsertAssessment,
  moods, type Mood, type InsertMood, 
  carePlans, type CarePlan, type InsertCarePlan,
  goals, type Goal, type InsertGoal
} from "@shared/schema";
import session from "express-session";
import createMemoryStore from "memorystore";

const MemoryStore = createMemoryStore(session);

export interface IStorage {
  // User
  getUser(id: number): Promise<User | undefined>;
  getUserByUsername(username: string): Promise<User | undefined>;
  createUser(user: InsertUser): Promise<User>;
  
  // Assessment
  createAssessment(assessment: InsertAssessment): Promise<Assessment>;
  getAssessmentsByUserId(userId: number): Promise<Assessment[]>;
  getLatestAssessmentByUserId(userId: number): Promise<Assessment | undefined>;
  
  // Mood
  createMood(mood: InsertMood): Promise<Mood>;
  getMoodsByUserId(userId: number): Promise<Mood[]>;
  getTodaysMood(userId: number): Promise<Mood | undefined>;
  
  // Care Plan
  createCarePlan(carePlan: InsertCarePlan): Promise<CarePlan>;
  getLatestCarePlanByUserId(userId: number): Promise<CarePlan | undefined>;
  
  // Goals
  createGoal(goal: InsertGoal): Promise<Goal>;
  getGoalsByUserId(userId: number): Promise<Goal[]>;
  getGoalById(id: number): Promise<Goal | undefined>;
  updateGoalCompletion(id: number, completed: boolean): Promise<Goal | undefined>;
  
  sessionStore: session.SessionStore;
}

export class MemStorage implements IStorage {
  private users: Map<number, User>;
  private assessments: Map<number, Assessment>;
  private moods: Map<number, Mood>;
  private carePlans: Map<number, CarePlan>;
  private goals: Map<number, Goal>;
  sessionStore: session.SessionStore;
  currentUserId: number;
  currentAssessmentId: number;
  currentMoodId: number;
  currentCarePlanId: number;
  currentGoalId: number;

  constructor() {
    this.users = new Map();
    this.assessments = new Map();
    this.moods = new Map();
    this.carePlans = new Map();
    this.goals = new Map();
    this.currentUserId = 1;
    this.currentAssessmentId = 1;
    this.currentMoodId = 1;
    this.currentCarePlanId = 1;
    this.currentGoalId = 1;
    this.sessionStore = new MemoryStore({
      checkPeriod: 86400000 // 24 hours
    });
  }

  // User methods
  async getUser(id: number): Promise<User | undefined> {
    return this.users.get(id);
  }

  async getUserByUsername(username: string): Promise<User | undefined> {
    return Array.from(this.users.values()).find(
      (user) => user.username === username,
    );
  }

  async createUser(insertUser: InsertUser): Promise<User> {
    const id = this.currentUserId++;
    const user: User = { ...insertUser, id };
    this.users.set(id, user);
    return user;
  }

  // Assessment methods
  async createAssessment(insertAssessment: InsertAssessment): Promise<Assessment> {
    const id = this.currentAssessmentId++;
    const date = new Date();
    const assessment: Assessment = { ...insertAssessment, id, date };
    this.assessments.set(id, assessment);
    return assessment;
  }

  async getAssessmentsByUserId(userId: number): Promise<Assessment[]> {
    return Array.from(this.assessments.values())
      .filter(assessment => assessment.userId === userId)
      .sort((a, b) => b.date.getTime() - a.date.getTime());
  }

  async getLatestAssessmentByUserId(userId: number): Promise<Assessment | undefined> {
    const userAssessments = await this.getAssessmentsByUserId(userId);
    return userAssessments.length > 0 ? userAssessments[0] : undefined;
  }

  // Mood methods
  async createMood(insertMood: InsertMood): Promise<Mood> {
    const id = this.currentMoodId++;
    const date = new Date();
    const mood: Mood = { ...insertMood, id, date };
    this.moods.set(id, mood);
    return mood;
  }

  async getMoodsByUserId(userId: number): Promise<Mood[]> {
    return Array.from(this.moods.values())
      .filter(mood => mood.userId === userId)
      .sort((a, b) => b.date.getTime() - a.date.getTime());
  }

  async getTodaysMood(userId: number): Promise<Mood | undefined> {
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    
    return Array.from(this.moods.values())
      .find(mood => {
        const moodDate = new Date(mood.date);
        moodDate.setHours(0, 0, 0, 0);
        return mood.userId === userId && moodDate.getTime() === today.getTime();
      });
  }

  // Care Plan methods
  async createCarePlan(insertCarePlan: InsertCarePlan): Promise<CarePlan> {
    const id = this.currentCarePlanId++;
    const date = new Date();
    const carePlan: CarePlan = { ...insertCarePlan, id, date };
    this.carePlans.set(id, carePlan);
    return carePlan;
  }

  async getLatestCarePlanByUserId(userId: number): Promise<CarePlan | undefined> {
    return Array.from(this.carePlans.values())
      .filter(plan => plan.userId === userId)
      .sort((a, b) => b.date.getTime() - a.date.getTime())
      [0];
  }

  // Goals methods
  async createGoal(insertGoal: InsertGoal): Promise<Goal> {
    const id = this.currentGoalId++;
    const date = new Date();
    const goal: Goal = { ...insertGoal, id, date };
    this.goals.set(id, goal);
    return goal;
  }

  async getGoalsByUserId(userId: number): Promise<Goal[]> {
    return Array.from(this.goals.values())
      .filter(goal => goal.userId === userId)
      .sort((a, b) => b.date.getTime() - a.date.getTime());
  }

  async getGoalById(id: number): Promise<Goal | undefined> {
    return this.goals.get(id);
  }

  async updateGoalCompletion(id: number, completed: boolean): Promise<Goal | undefined> {
    const goal = await this.getGoalById(id);
    if (goal) {
      const updatedGoal = { ...goal, completed };
      this.goals.set(id, updatedGoal);
      return updatedGoal;
    }
    return undefined;
  }
}

export const storage = new MemStorage();
