import { Button } from "@/components/ui/button";
import { RadioGroup, RadioGroupItem } from "@/components/ui/radio-group";
import { Label } from "@/components/ui/label";

interface AssessmentQuestion {
  id: number;
  question: string;
  options: {
    value: number;
    label: string;
  }[];
}

interface AssessmentFormProps {
  question: AssessmentQuestion;
  onAnswer: (value: number) => void;
  onPrevious: () => void;
  isFirstQuestion: boolean;
}

export function AssessmentForm({ 
  question, 
  onAnswer, 
  onPrevious, 
  isFirstQuestion 
}: AssessmentFormProps) {
  const handleSelectionChange = (value: string) => {
    onAnswer(parseInt(value, 10));
  };

  return (
    <div className="question">
      <h2 className="font-semibold text-lg mb-4">{question.question}</h2>
      
      <RadioGroup 
        className="space-y-3 mb-8"
        onValueChange={handleSelectionChange}
      >
        {question.options.map((option) => (
          <div 
            key={option.value}
            className="bg-neutral-50 rounded-lg border border-neutral-200 p-4 cursor-pointer hover:border-primary transition-colors"
          >
            <div className="flex items-center">
              <RadioGroupItem value={option.value.toString()} id={`option-${question.id}-${option.value}`} />
              <Label 
                htmlFor={`option-${question.id}-${option.value}`}
                className="ml-2 font-medium cursor-pointer"
              >
                {option.label}
              </Label>
            </div>
          </div>
        ))}
      </RadioGroup>
      
      <div className="flex justify-between">
        <Button 
          variant="outline" 
          onClick={onPrevious}
          disabled={isFirstQuestion}
        >
          Previous
        </Button>
      </div>
    </div>
  );
}
