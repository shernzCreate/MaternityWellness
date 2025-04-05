import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";
import { useState, useEffect } from "react";
import { useLocation } from "wouter";
import {
  Form,
  FormControl,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from "@/components/ui/form";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import { useAuth } from "@/hooks/use-auth";
import { Checkbox } from "@/components/ui/checkbox";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { FaGoogle, FaApple } from "react-icons/fa";
import { Separator } from "@/components/ui/separator";

const loginSchema = z.object({
  username: z.string().email("Please enter a valid email"),
  password: z.string().min(1, "Password is required"),
});

const signupSchema = z.object({
  username: z.string().email("Please enter a valid email"),
  password: z.string()
    .min(8, "Password must be at least 8 characters")
    .regex(/[0-9]/, "Password must contain at least one number")
    .regex(/[^a-zA-Z0-9]/, "Password must contain at least one special character"),
  fullName: z.string().min(1, "Full name is required"),
  birthDate: z.string().optional(),
  termsAgreed: z.boolean().refine(val => val === true, {
    message: "You must agree to the terms and conditions",
  }),
});

type LoginFormValues = z.infer<typeof loginSchema>;
type SignupFormValues = z.infer<typeof signupSchema>;

export default function AuthPage() {
  const [activeTab, setActiveTab] = useState<"login" | "signup">("login");
  const { user, loginMutation, registerMutation } = useAuth();
  const [location, navigate] = useLocation();

  // Redirect if already logged in
  useEffect(() => {
    if (user) {
      navigate("/");
    }
  }, [user, navigate]);

  const loginForm = useForm<LoginFormValues>({
    resolver: zodResolver(loginSchema),
    defaultValues: {
      username: "",
      password: "",
    },
  });

  const signupForm = useForm<SignupFormValues>({
    resolver: zodResolver(signupSchema),
    defaultValues: {
      username: "",
      password: "",
      fullName: "",
      birthDate: "",
      termsAgreed: false,
    },
  });

  const handleLogin = async (data: LoginFormValues) => {
    await loginMutation.mutateAsync(data);
  };

  const handleSignup = async (data: SignupFormValues) => {
    const { termsAgreed, ...userData } = data;
    await registerMutation.mutateAsync(userData);
  };

  return (
    <div className="min-h-screen grid md:grid-cols-2">
      {/* Left column: Form */}
      <div className="flex items-center justify-center p-6 bg-white">
        <div className="w-full max-w-md">
          <div className="text-center mb-8">
            <h1 className="text-3xl font-bold text-primary mb-2 font-heading">Maternal Wellness</h1>
            <p className="text-neutral-600">Support for your postpartum journey</p>
          </div>

          <Tabs value={activeTab} onValueChange={(val) => setActiveTab(val as "login" | "signup")}>
            <TabsList className="grid grid-cols-2 mb-6">
              <TabsTrigger value="login">Log In</TabsTrigger>
              <TabsTrigger value="signup">Sign Up</TabsTrigger>
            </TabsList>

            {/* Login Form */}
            <TabsContent value="login">
              <Form {...loginForm}>
                <form onSubmit={loginForm.handleSubmit(handleLogin)} className="space-y-4">
                  <FormField
                    control={loginForm.control}
                    name="username"
                    render={({ field }) => (
                      <FormItem>
                        <FormLabel>Email</FormLabel>
                        <FormControl>
                          <Input 
                            placeholder="Enter your email" 
                            {...field} 
                            type="email"
                          />
                        </FormControl>
                        <FormMessage />
                      </FormItem>
                    )}
                  />

                  <FormField
                    control={loginForm.control}
                    name="password"
                    render={({ field }) => (
                      <FormItem>
                        <div className="flex justify-between items-baseline">
                          <FormLabel>Password</FormLabel>
                          <a href="#" className="text-sm text-primary hover:text-primary-dark transition-colors">
                            Forgot password?
                          </a>
                        </div>
                        <FormControl>
                          <Input 
                            placeholder="Enter your password" 
                            type="password" 
                            {...field} 
                          />
                        </FormControl>
                        <FormMessage />
                      </FormItem>
                    )}
                  />

                  <Button 
                    type="submit" 
                    className="w-full" 
                    disabled={loginMutation.isPending}
                  >
                    {loginMutation.isPending ? "Logging in..." : "Log In"}
                  </Button>
                </form>
              </Form>

              <div className="mt-6">
                <div className="relative flex items-center py-2">
                  <div className="flex-grow border-t border-neutral-300"></div>
                  <span className="flex-shrink mx-4 text-neutral-500 text-sm">or continue with</span>
                  <div className="flex-grow border-t border-neutral-300"></div>
                </div>

                <div className="mt-4 flex space-x-4">
                  <Button variant="outline" className="flex-1 flex items-center gap-2">
                    <FaGoogle className="h-4 w-4" />
                    <span>Google</span>
                  </Button>
                  <Button variant="outline" className="flex-1 flex items-center gap-2">
                    <FaApple className="h-4 w-4" />
                    <span>Apple</span>
                  </Button>
                </div>
              </div>
            </TabsContent>

            {/* Signup Form */}
            <TabsContent value="signup">
              <Form {...signupForm}>
                <form onSubmit={signupForm.handleSubmit(handleSignup)} className="space-y-4">
                  <FormField
                    control={signupForm.control}
                    name="fullName"
                    render={({ field }) => (
                      <FormItem>
                        <FormLabel>Full Name</FormLabel>
                        <FormControl>
                          <Input placeholder="Enter your full name" {...field} />
                        </FormControl>
                        <FormMessage />
                      </FormItem>
                    )}
                  />

                  <FormField
                    control={signupForm.control}
                    name="username"
                    render={({ field }) => (
                      <FormItem>
                        <FormLabel>Email</FormLabel>
                        <FormControl>
                          <Input 
                            placeholder="Enter your email" 
                            {...field} 
                            type="email"
                          />
                        </FormControl>
                        <FormMessage />
                      </FormItem>
                    )}
                  />

                  <FormField
                    control={signupForm.control}
                    name="password"
                    render={({ field }) => (
                      <FormItem>
                        <FormLabel>Password</FormLabel>
                        <FormControl>
                          <Input 
                            placeholder="Create a password" 
                            type="password" 
                            {...field} 
                          />
                        </FormControl>
                        <p className="text-xs text-neutral-500 mt-1">
                          Must be at least 8 characters with a number and special character
                        </p>
                        <FormMessage />
                      </FormItem>
                    )}
                  />

                  <FormField
                    control={signupForm.control}
                    name="birthDate"
                    render={({ field }) => (
                      <FormItem>
                        <FormLabel>Baby's Birth Date</FormLabel>
                        <FormControl>
                          <Input type="date" {...field} />
                        </FormControl>
                        <FormMessage />
                      </FormItem>
                    )}
                  />

                  <FormField
                    control={signupForm.control}
                    name="termsAgreed"
                    render={({ field }) => (
                      <FormItem className="flex flex-row items-start space-x-3 space-y-0 rounded-md">
                        <FormControl>
                          <Checkbox
                            checked={field.value}
                            onCheckedChange={field.onChange}
                          />
                        </FormControl>
                        <div className="space-y-1 leading-none">
                          <FormLabel className="text-sm text-neutral-600">
                            I agree to the <a href="#" className="text-primary">Terms of Service</a> and <a href="#" className="text-primary">Privacy Policy</a>
                          </FormLabel>
                          <FormMessage />
                        </div>
                      </FormItem>
                    )}
                  />

                  <Button 
                    type="submit" 
                    className="w-full" 
                    disabled={registerMutation.isPending}
                  >
                    {registerMutation.isPending ? "Creating Account..." : "Create Account"}
                  </Button>
                </form>
              </Form>
            </TabsContent>
          </Tabs>
        </div>
      </div>

      {/* Right column: Hero Image */}
      <div className="hidden md:block bg-gradient-to-br from-primary to-primary-light text-white">
        <div className="flex flex-col h-full justify-center items-center p-12">
          <div className="max-w-md text-center">
            <h2 className="text-4xl font-bold mb-6 font-heading">Supporting Your Postpartum Journey</h2>
            <p className="text-lg mb-8">
              Get personalized support, track your emotions, and connect with resources to help you navigate the challenges of early motherhood.
            </p>
            <div className="grid grid-cols-2 gap-6">
              <div className="bg-white bg-opacity-10 p-4 rounded-lg">
                <h3 className="text-xl font-semibold mb-2">Self-Assessment</h3>
                <p>Regular check-ins to monitor your emotional wellbeing</p>
              </div>
              <div className="bg-white bg-opacity-10 p-4 rounded-lg">
                <h3 className="text-xl font-semibold mb-2">Resources</h3>
                <p>Expert information on postpartum depression and wellness</p>
              </div>
              <div className="bg-white bg-opacity-10 p-4 rounded-lg">
                <h3 className="text-xl font-semibold mb-2">Care Plans</h3>
                <p>Personalized recommendations tailored to your needs</p>
              </div>
              <div className="bg-white bg-opacity-10 p-4 rounded-lg">
                <h3 className="text-xl font-semibold mb-2">Support</h3>
                <p>Connect with professionals and peer support networks</p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
