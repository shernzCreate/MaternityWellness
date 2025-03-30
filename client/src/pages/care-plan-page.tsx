import { useState } from "react";
import { AppLayout } from "@/components/app-layout";
import { Button } from "@/components/ui/button";
import { Checkbox } from "@/components/ui/checkbox";
import { useQuery, useMutation } from "@tanstack/react-query";
import { apiRequest, queryClient } from "@/lib/queryClient";
import { format } from "date-fns";
import { ArrowRight, Check, ChevronDown, Plus } from "lucide-react";
import { CarePlanItem } from "@/components/care-plan-item";
import { Collapsible, CollapsibleContent, CollapsibleTrigger } from "@/components/ui/collapsible";
import { useLocation } from "wouter";

interface GoalItem {
  id: number;
  title: string;
  description: string;
  completed: boolean;
  userId: number;
}

export default function CarePlanPage() {
  const [, navigate] = useLocation();
  const [openSections, setOpenSections] = useState<Record<string, boolean>>({
    mind: true,
    body: true,
    support: true
  });

  // Fetch the latest care plan
  const { data: carePlan, isLoading: carePlanLoading } = useQuery({
    queryKey: ["/api/care-plans/latest"],
    queryFn: async () => {
      try {
        const response = await fetch("/api/care-plans/latest");
        if (!response.ok) {
          if (response.status === 404) {
            return null;
          }
          throw new Error("Failed to fetch care plan");
        }
        return await response.json();
      } catch (error) {
        console.error("Error fetching care plan:", error);
        return null;
      }
    }
  });

  // Fetch goals
  const { data: goals = [], isLoading: goalsLoading } = useQuery({
    queryKey: ["/api/goals"],
    queryFn: async () => {
      const response = await fetch("/api/goals");
      if (!response.ok) throw new Error("Failed to fetch goals");
      return response.json();
    }
  });

  // Toggle goal completion
  const toggleGoalMutation = useMutation({
    mutationFn: async ({ id, completed }: { id: number, completed: boolean }) => {
      const res = await apiRequest("PATCH", `/api/goals/${id}`, { completed });
      return res.json();
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["/api/goals"] });
    }
  });

  const handleGoalToggle = (id: number, completed: boolean) => {
    toggleGoalMutation.mutate({ id, completed: !completed });
  };

  const toggleSection = (section: string) => {
    setOpenSections({
      ...openSections,
      [section]: !openSections[section]
    });
  };

  return (
    <AppLayout>
      <div className="bg-primary text-white px-4 py-6">
        <h1 className="font-bold text-xl mb-4">Your Care Plan</h1>
        
        <p className="text-primary-light text-sm mb-3">
          Personalized recommendations based on your wellness check-ins.
        </p>
        
        <div className="bg-white bg-opacity-10 rounded-xl p-3 flex items-center justify-between">
          <div>
            <span className="text-xs opacity-80">Last updated</span>
            <p className="font-medium">
              {carePlan ? format(new Date(carePlan.date), 'MMM d, yyyy') : 'No plan yet'}
            </p>
          </div>
          <Button 
            className="bg-white text-primary hover:bg-opacity-90"
            onClick={() => navigate('/assessment')}
          >
            Update Plan
          </Button>
        </div>
      </div>
      
      {/* Daily Goals Section */}
      <div className="px-4 py-6">
        <div className="flex items-center justify-between mb-4">
          <h2 className="font-semibold text-lg">Today's Goals</h2>
          <button className="text-sm text-primary font-medium">Edit</button>
        </div>
        
        <div className="space-y-3 mb-8">
          {goalsLoading ? (
            <p>Loading goals...</p>
          ) : goals.length > 0 ? (
            goals.map((goal: GoalItem) => (
              <div key={goal.id} className="bg-white rounded-xl shadow-sm p-4">
                <label className="flex items-start">
                  <Checkbox 
                    checked={goal.completed}
                    onCheckedChange={() => handleGoalToggle(goal.id, goal.completed)}
                    className="mt-1 h-5 w-5"
                  />
                  <div className="ml-3">
                    <p className={`font-medium ${goal.completed ? "line-through text-muted-foreground" : ""}`}>
                      {goal.title}
                    </p>
                    <p className="text-sm text-muted-foreground">{goal.description}</p>
                  </div>
                </label>
              </div>
            ))
          ) : (
            <p>No goals set yet.</p>
          )}
          
          <Button 
            variant="outline" 
            className="w-full border border-dashed border-muted-foreground p-4 text-center text-muted-foreground hover:border-primary hover:text-primary"
          >
            <Plus className="h-4 w-4 mr-1" /> Add Custom Goal
          </Button>
        </div>
        
        {/* Care Plan Components */}
        {carePlanLoading ? (
          <p>Loading your care plan...</p>
        ) : carePlan ? (
          <>
            <h2 className="font-semibold text-lg mb-4">Your Care Plan Components</h2>
            
            <div className="space-y-4 mb-6">
              {/* Mind & Emotions */}
              <Collapsible open={openSections.mind}>
                <div className="bg-accent bg-opacity-10 px-4 py-3 flex justify-between items-center rounded-t-xl">
                  <h3 className="font-semibold text-accent-dark">Mind & Emotions</h3>
                  <CollapsibleTrigger asChild>
                    <Button 
                      variant="ghost" 
                      size="icon" 
                      className="p-1 rounded-full hover:bg-accent hover:bg-opacity-10 text-accent-dark"
                      onClick={() => toggleSection('mind')}
                    >
                      <ChevronDown className={`h-5 w-5 transition-transform ${openSections.mind ? '' : 'transform rotate-180'}`} />
                    </Button>
                  </CollapsibleTrigger>
                </div>
                <CollapsibleContent className="bg-white rounded-b-xl shadow-sm">
                  <div className="p-4">
                    <div className="space-y-3">
                      {carePlan.plan.mindAndEmotions.map((item: any, index: number) => (
                        <CarePlanItem 
                          key={index}
                          title={item.title}
                          description={item.description}
                          type="mind"
                        />
                      ))}
                    </div>
                    
                    <Button variant="link" className="mt-4 px-0 text-accent font-medium text-sm flex items-center">
                      View Detailed Plan <ArrowRight className="h-4 w-4 ml-1" />
                    </Button>
                  </div>
                </CollapsibleContent>
              </Collapsible>
              
              {/* Body & Rest */}
              <Collapsible open={openSections.body}>
                <div className="bg-secondary bg-opacity-10 px-4 py-3 flex justify-between items-center rounded-t-xl">
                  <h3 className="font-semibold text-secondary-dark">Body & Rest</h3>
                  <CollapsibleTrigger asChild>
                    <Button 
                      variant="ghost" 
                      size="icon" 
                      className="p-1 rounded-full hover:bg-secondary hover:bg-opacity-10 text-secondary-dark"
                      onClick={() => toggleSection('body')}
                    >
                      <ChevronDown className={`h-5 w-5 transition-transform ${openSections.body ? '' : 'transform rotate-180'}`} />
                    </Button>
                  </CollapsibleTrigger>
                </div>
                <CollapsibleContent className="bg-white rounded-b-xl shadow-sm">
                  <div className="p-4">
                    <div className="space-y-3">
                      {carePlan.plan.bodyAndRest.map((item: any, index: number) => (
                        <CarePlanItem 
                          key={index}
                          title={item.title}
                          description={item.description}
                          type="body"
                        />
                      ))}
                    </div>
                    
                    <Button variant="link" className="mt-4 px-0 text-secondary font-medium text-sm flex items-center">
                      View Detailed Plan <ArrowRight className="h-4 w-4 ml-1" />
                    </Button>
                  </div>
                </CollapsibleContent>
              </Collapsible>
              
              {/* Support & Connection */}
              <Collapsible open={openSections.support}>
                <div className="bg-primary bg-opacity-10 px-4 py-3 flex justify-between items-center rounded-t-xl">
                  <h3 className="font-semibold text-primary-dark">Support & Connection</h3>
                  <CollapsibleTrigger asChild>
                    <Button 
                      variant="ghost" 
                      size="icon" 
                      className="p-1 rounded-full hover:bg-primary hover:bg-opacity-10 text-primary-dark"
                      onClick={() => toggleSection('support')}
                    >
                      <ChevronDown className={`h-5 w-5 transition-transform ${openSections.support ? '' : 'transform rotate-180'}`} />
                    </Button>
                  </CollapsibleTrigger>
                </div>
                <CollapsibleContent className="bg-white rounded-b-xl shadow-sm">
                  <div className="p-4">
                    <div className="space-y-3">
                      {carePlan.plan.supportAndConnection.map((item: any, index: number) => (
                        <CarePlanItem 
                          key={index}
                          title={item.title}
                          description={item.description}
                          type="support"
                        />
                      ))}
                    </div>
                    
                    <Button variant="link" className="mt-4 px-0 text-primary font-medium text-sm flex items-center">
                      View Detailed Plan <ArrowRight className="h-4 w-4 ml-1" />
                    </Button>
                  </div>
                </CollapsibleContent>
              </Collapsible>
            </div>
            
            {/* Track Progress */}
            <div className="bg-white rounded-xl shadow-sm p-4 mb-8">
              <h3 className="font-semibold mb-3">Track Your Progress</h3>
              <p className="text-sm text-muted-foreground mb-4">
                Regularly monitor how you're feeling to see your improvement over time.
              </p>
              <Button 
                className="w-full"
              >
                View Progress Charts
              </Button>
            </div>
          </>
        ) : (
          <div className="text-center p-6">
            <div className="mb-4">No care plan found.</div>
            <Button onClick={() => navigate('/assessment')}>
              Complete Assessment to Get a Plan
            </Button>
          </div>
        )}
      </div>
    </AppLayout>
  );
}
