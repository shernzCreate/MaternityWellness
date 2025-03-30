import { pgTable, text, serial, integer, boolean, timestamp, json } from "drizzle-orm/pg-core";
import { createInsertSchema } from "drizzle-zod";
import { z } from "zod";

export const users = pgTable("users", {
  id: serial("id").primaryKey(),
  username: text("username").notNull().unique(),
  password: text("password").notNull(),
  fullName: text("full_name").notNull(),
  birthDate: text("birth_date"),
  createdAt: timestamp("created_at").defaultNow(),
});

export const assessments = pgTable("assessments", {
  id: serial("id").primaryKey(),
  userId: integer("user_id").notNull(),
  date: timestamp("date").defaultNow(),
  score: integer("score").notNull(),
  answers: json("answers").notNull(),
});

export const moods = pgTable("moods", {
  id: serial("id").primaryKey(),
  userId: integer("user_id").notNull(),
  date: timestamp("date").defaultNow(),
  mood: text("mood").notNull(),
  notes: text("notes"),
});

export const carePlans = pgTable("care_plans", {
  id: serial("id").primaryKey(),
  userId: integer("user_id").notNull(),
  date: timestamp("date").defaultNow(),
  plan: json("plan").notNull(),
});

export const goals = pgTable("goals", {
  id: serial("id").primaryKey(),
  userId: integer("user_id").notNull(),
  carePlanId: integer("care_plan_id"),
  title: text("title").notNull(),
  description: text("description"),
  completed: boolean("completed").default(false),
  date: timestamp("date").defaultNow(),
});

// Insert schemas
export const insertUserSchema = createInsertSchema(users).pick({
  username: true,
  password: true,
  fullName: true,
  birthDate: true,
});

export const insertAssessmentSchema = createInsertSchema(assessments).pick({
  userId: true,
  score: true,
  answers: true,
});

export const insertMoodSchema = createInsertSchema(moods).pick({
  userId: true,
  mood: true,
  notes: true,
});

export const insertCarePlanSchema = createInsertSchema(carePlans).pick({
  userId: true,
  plan: true,
});

export const insertGoalSchema = createInsertSchema(goals).pick({
  userId: true,
  carePlanId: true,
  title: true,
  description: true,
  completed: true,
});

// Types
export type InsertUser = z.infer<typeof insertUserSchema>;
export type User = typeof users.$inferSelect;

export type InsertAssessment = z.infer<typeof insertAssessmentSchema>;
export type Assessment = typeof assessments.$inferSelect;

export type InsertMood = z.infer<typeof insertMoodSchema>;
export type Mood = typeof moods.$inferSelect;

export type InsertCarePlan = z.infer<typeof insertCarePlanSchema>;
export type CarePlan = typeof carePlans.$inferSelect;

export type InsertGoal = z.infer<typeof insertGoalSchema>;
export type Goal = typeof goals.$inferSelect;
