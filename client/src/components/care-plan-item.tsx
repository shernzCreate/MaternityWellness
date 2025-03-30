import { 
  Heart, 
  BookOpen, 
  Users, 
  Brain, 
  Sparkles, 
  Bed, 
  Footprints
} from "lucide-react";

interface CarePlanItemProps {
  title: string;
  description: string;
  type: "mind" | "body" | "support";
}

export function CarePlanItem({ title, description, type }: CarePlanItemProps) {
  // Select icon based on type and title keywords
  const getIcon = () => {
    if (type === "mind") {
      if (title.toLowerCase().includes("mindful")) return Brain;
      return Sparkles;
    } else if (type === "body") {
      if (title.toLowerCase().includes("sleep")) return Bed;
      return Footprints;
    } else {
      // Support
      if (title.toLowerCase().includes("group")) return Users;
      if (title.toLowerCase().includes("communicat")) return BookOpen;
      return Heart;
    }
  };
  
  // Get color class based on type
  const getColorClass = () => {
    switch (type) {
      case "mind":
        return "bg-accent bg-opacity-20 text-accent";
      case "body":
        return "bg-secondary bg-opacity-20 text-secondary";
      case "support":
        return "bg-primary bg-opacity-20 text-primary";
    }
  };
  
  const Icon = getIcon();
  const colorClass = getColorClass();
  
  return (
    <div className="flex items-start">
      <div className={`w-6 h-6 ${colorClass} rounded-full flex items-center justify-center flex-shrink-0 mt-0.5`}>
        <Icon className="h-3 w-3" />
      </div>
      <div className="ml-3">
        <p className="font-medium">{title}</p>
        <p className="text-sm text-neutral-500">{description}</p>
      </div>
    </div>
  );
}
