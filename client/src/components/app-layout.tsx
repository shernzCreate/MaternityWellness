import { ReactNode } from "react";
import { BottomNavigation } from "./bottom-navigation";
import { useAuth } from "@/hooks/use-auth";

interface AppLayoutProps {
  children: ReactNode;
  activeTab?: "home" | "progress" | "learn" | "profile";
}

export function AppLayout({ children, activeTab = "home" }: AppLayoutProps) {
  const { user } = useAuth();
  
  return (
    <div className="min-h-screen bg-neutral-50 pb-20">
      {children}
      <BottomNavigation activeTab={activeTab} />
    </div>
  );
}
