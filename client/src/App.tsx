import { Switch, Route } from "wouter";
import { queryClient } from "./lib/queryClient";
import { QueryClientProvider } from "@tanstack/react-query";
import { Toaster } from "@/components/ui/toaster";
import NotFound from "@/pages/not-found";
import AuthPage from "@/pages/auth-page";
import HomePage from "@/pages/home-page";
import AssessmentPage from "@/pages/assessment-page";
import ResourcesPage from "@/pages/resources-page";
import CarePlanPage from "@/pages/care-plan-page";
import CommunityPage from "@/pages/community-page";
import ProfilePage from "@/pages/profile-page";
import InProgressPage from "@/pages/in-progress-page";
import { ProtectedRoute } from "./lib/protected-route";
import { AuthProvider } from "./hooks/use-auth";
import { isInNativeApp, getPlatformName } from "./lib/nativeBridge";
import { useEffect } from "react";

function App() {
  useEffect(() => {
    if (isInNativeApp()) {
      console.log(`Running in ${getPlatformName()}`);
      
      // Apply native app specific styles or behaviors
      document.documentElement.classList.add('native-app');
      if (document.documentElement.classList.contains('ios-app')) {
        document.documentElement.classList.add('ios-app');
      }
    }
  }, []);

  return (
    <QueryClientProvider client={queryClient}>
      <AuthProvider>
        <AppRoutes />
        <Toaster />
      </AuthProvider>
    </QueryClientProvider>
  );
}

function AppRoutes() {
  return (
    <Switch>
      <ProtectedRoute path="/" component={HomePage} />
      <ProtectedRoute path="/assessment" component={AssessmentPage} />
      <ProtectedRoute path="/resources" component={ResourcesPage} />
      <ProtectedRoute path="/care-plan" component={CarePlanPage} />
      <ProtectedRoute path="/community" component={CommunityPage} />
      <ProtectedRoute path="/profile" component={ProfilePage} />
      <ProtectedRoute path="/progress" component={InProgressPage} />
      <Route path="/auth" component={AuthPage} />
      <Route component={NotFound} />
    </Switch>
  );
}

export default App;
