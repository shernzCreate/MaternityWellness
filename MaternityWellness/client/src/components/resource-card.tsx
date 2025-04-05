import { Card, CardContent } from "@/components/ui/card";
import { ArrowRight } from "lucide-react";

interface Resource {
  id: number;
  title: string;
  description: string;
  readTime: number;
  type: string;
  featured?: boolean;
}

interface ResourceCardProps {
  resource: Resource;
  isFeatured?: boolean;
  isCompact?: boolean;
}

export function ResourceCard({ resource, isFeatured = false, isCompact = false }: ResourceCardProps) {
  const { title, description, readTime, type } = resource;
  
  // For featured (large) cards
  if (isFeatured) {
    return (
      <Card className="overflow-hidden cursor-pointer hover:shadow-md transition-shadow">
        <div className="h-40 bg-neutral-200 relative">
          {type === 'video' ? (
            <div className="w-full h-full flex items-center justify-center bg-accent bg-opacity-20">
              <svg xmlns="http://www.w3.org/2000/svg" width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" className="text-accent">
                <polygon points="5 3 19 12 5 21 5 3"></polygon>
              </svg>
            </div>
          ) : (
            <div className="w-full h-full flex items-center justify-center bg-primary-light bg-opacity-20">
              <svg xmlns="http://www.w3.org/2000/svg" width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" className="text-primary">
                <path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"></path>
                <path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"></path>
              </svg>
            </div>
          )}
          <div className="absolute top-3 right-3 bg-white bg-opacity-90 px-2 py-1 rounded text-xs font-medium">
            Featured
          </div>
        </div>
        <CardContent className="p-4">
          <h3 className="font-heading font-semibold text-lg mb-1">{title}</h3>
          <p className="text-neutral-600 text-sm mb-3">{description}</p>
          <div className="flex items-center justify-between">
            <span className="text-xs text-neutral-500">
              {type === 'video' ? `Video • ${readTime} min` : `${readTime} min read`}
            </span>
            <span className="flex items-center text-primary text-sm font-medium">
              {type === 'video' ? 'Watch' : 'Read Article'} <ArrowRight className="h-4 w-4 ml-1" />
            </span>
          </div>
        </CardContent>
      </Card>
    );
  }
  
  // For compact (list) cards
  return (
    <Card className="flex overflow-hidden cursor-pointer hover:shadow-md transition-shadow">
      <div className="w-24 h-24 bg-neutral-200 flex-shrink-0">
        {type === 'video' ? (
          <div className="w-full h-full flex items-center justify-center bg-accent bg-opacity-20">
            <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" className="text-accent">
              <polygon points="5 3 19 12 5 21 5 3"></polygon>
            </svg>
          </div>
        ) : (
          <div className="w-full h-full flex items-center justify-center bg-primary-light bg-opacity-20">
            <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" className="text-primary">
              <path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"></path>
              <path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"></path>
            </svg>
          </div>
        )}
      </div>
      <CardContent className="p-3 flex-1">
        <h3 className="font-heading font-semibold text-base mb-1">{title}</h3>
        <p className="text-neutral-600 text-xs mb-2">{description}</p>
        <div className="flex items-center justify-between">
          <span className="text-xs text-neutral-500">
            {type === 'video' ? `Video • ${readTime} min` : `${readTime} min read`}
          </span>
          <span className="flex items-center text-primary text-xs font-medium">
            {type === 'video' ? 'Watch' : 'Read'} <ArrowRight className="h-3 w-3 ml-1" />
          </span>
        </div>
      </CardContent>
    </Card>
  );
}
