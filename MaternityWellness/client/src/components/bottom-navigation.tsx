import { useLocation } from "wouter";
import { Home, BarChart2, BookOpen, User, MessageCircle } from "lucide-react";

interface BottomNavigationProps {
  activeTab: "home" | "progress" | "learn" | "profile" | "community";
}

export function BottomNavigation({ activeTab }: BottomNavigationProps) {
  const [, navigate] = useLocation();
  
  const tabs = [
    { id: "home", label: "Home", icon: Home, path: "/" },
    { id: "progress", label: "Progress", icon: BarChart2, path: "/progress" },
    { id: "learn", label: "Learn", icon: BookOpen, path: "/resources" },
    { id: "community", label: "Community", icon: MessageCircle, path: "/community" },
    { id: "profile", label: "Profile", icon: User, path: "/profile" }
  ];
  
  return (
    <div className="fixed bottom-0 left-0 right-0 bg-white border-t border-neutral-200 px-2 pt-2 pb-6">
      <div className="flex justify-around">
        {tabs.map(tab => (
          <button 
            key={tab.id}
            className={`flex flex-col items-center w-16 py-1 ${activeTab === tab.id ? 'text-primary' : 'text-neutral-400 hover:text-primary'} transition-colors`}
            onClick={() => navigate(tab.path)}
          >
            <tab.icon className="h-5 w-5" />
            <span className="text-xs mt-1">{tab.label}</span>
          </button>
        ))}
      </div>
    </div>
  );
}
