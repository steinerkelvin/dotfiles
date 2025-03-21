import { z } from 'zod';

/**
 * Definition for an argument
 */
export interface ArgDef {
  schema: z.ZodType<any>;
  description?: string;
  short?: string | null;
  default?: any;
  required?: boolean;
}

/**
 * A single parsed argument
 */
export interface ParsedArg {
  value: any;
  provided: boolean;
}

/**
 * Type for all parsed arguments
 */
export type ParsedArgs = Record<string, ParsedArg>;

/**
 * Error in CLI argument parsing
 */
export class CliError extends Error {
  errors: string[];
  
  constructor(errors: string[] | string) {
    const messages = Array.isArray(errors) ? errors : [errors];
    super(messages.join('\n'));
    this.name = 'CliError';
    this.errors = messages;
  }
}

/**
 * Command builder class for CLI parsing
 */
export class Command {
  private description: string;
  private args: Map<string, ArgDef> = new Map();
  
  /**
   * Create a new command
   * @param options Command options
   */
  constructor(options: { description: string }) {
    this.description = options.description;
  }
  
  /**
   * Add an argument to the command
   * @param name Argument name
   * @param options Argument definition
   */
  arg(name: string, options: ArgDef): Command {
    this.args.set(name, options);
    return this;
  }
  
  /**
   * Parse command line arguments
   * @param args Command line arguments
   * @returns Parsed arguments
   */
  parse(args: string[]): { positional: string[]; args: ParsedArgs; rest: string[] } {
    // Initialize result with defaults
    const result: ParsedArgs = {};
    this.args.forEach((def, name) => {
      result[name] = {
        value: def.default,
        provided: false
      };
    });
    
    const positional: string[] = [];
    const rest: string[] = [];
    const errors: string[] = [];
    
    // Check for -- separator
    const separatorIndex = args.indexOf('--');
    const mainArgs = separatorIndex >= 0 ? args.slice(0, separatorIndex) : args;
    const restArgs = separatorIndex >= 0 ? args.slice(separatorIndex + 1) : [];
    
    rest.push(...restArgs);
    
    // Create a map of short names to argument names
    const shortNameMap = new Map<string, string>();
    this.args.forEach((def, name) => {
      if (def.short) {
        shortNameMap.set(def.short, name);
      }
    });
    
    // Parse arguments
    for (let i = 0; i < mainArgs.length; i++) {
      const arg = mainArgs[i];
      
      if (arg.startsWith('--')) {
        // Long form: --name or --name=value
        const hasEquals = arg.includes('=');
        const name = hasEquals ? arg.substring(2, arg.indexOf('=')) : arg.substring(2);
        
        // Check if arg exists
        if (!this.args.has(name)) {
          errors.push(`Unknown argument: ${name}`);
          continue;
        }
        
        const def = this.args.get(name)!;
        
        // Handle boolean flags (no value needed)
        if (def.schema instanceof z.ZodBoolean && !hasEquals) {
          result[name] = { value: true, provided: true };
          continue;
        }
        
        // Get value
        let value: string;
        if (hasEquals) {
          value = arg.substring(arg.indexOf('=') + 1);
        } else if (i + 1 < mainArgs.length && !mainArgs[i + 1].startsWith('-')) {
          value = mainArgs[i + 1];
          i++; // Skip next argument
        } else {
          errors.push(`Missing value for argument: ${name}`);
          continue;
        }
        
        // Parse and validate with zod
        try {
          result[name] = {
            value: def.schema.parse(value),
            provided: true
          };
        } catch (error) {
          if (error instanceof z.ZodError) {
            errors.push(`Invalid value for ${name}: ${error.errors[0].message}`);
          } else {
            errors.push(`Error parsing ${name}: ${error}`);
          }
        }
      } else if (arg.startsWith('-') && arg.length > 1) {
        // Short form: -n or -n value
        const shortName = arg.substring(1, 2);
        
        // Check if short name exists
        if (!shortNameMap.has(shortName)) {
          errors.push(`Unknown short argument: ${shortName}`);
          continue;
        }
        
        const name = shortNameMap.get(shortName)!;
        const def = this.args.get(name)!;
        
        // Handle boolean flags (no value needed)
        if (def.schema instanceof z.ZodBoolean) {
          result[name] = { value: true, provided: true };
          
          // If there are more short options in this arg, process them too
          if (arg.length > 2) {
            // Insert the remaining short options as a new argument
            mainArgs.splice(i + 1, 0, '-' + arg.substring(2));
          }
          continue;
        }
        
        // Get value
        let value: string;
        if (arg.length > 2) {
          // Value is in the same argument: -nvalue
          value = arg.substring(2);
        } else if (i + 1 < mainArgs.length && !mainArgs[i + 1].startsWith('-')) {
          value = mainArgs[i + 1];
          i++; // Skip next argument
        } else {
          errors.push(`Missing value for argument: ${name}`);
          continue;
        }
        
        // Parse and validate with zod
        try {
          result[name] = {
            value: def.schema.parse(value),
            provided: true
          };
        } catch (error) {
          if (error instanceof z.ZodError) {
            errors.push(`Invalid value for ${name}: ${error.errors[0].message}`);
          } else {
            errors.push(`Error parsing ${name}: ${error}`);
          }
        }
      } else {
        // Positional argument
        positional.push(arg);
      }
    }
    
    // Check for required arguments
    this.args.forEach((def, name) => {
      if (def.required && !result[name].provided) {
        errors.push(`Missing required argument: ${name}`);
      }
    });
    
    // Throw combined errors if any
    if (errors.length > 0) {
      throw new CliError(errors);
    }
    
    return { positional, args: result, rest };
  }
  
  /**
   * Generate help text for the command
   */
  help(): string {
    const lines: string[] = [this.description, '', 'Arguments:'];
    
    this.args.forEach((def, name) => {
      let line = '  ';
      
      // Add short name if available
      if (def.short) {
        line += `-${def.short}, `;
      }
      
      // Add long name
      line += `--${name}`;
      
      // Add value hint based on schema type
      const schema = def.schema;
      if (!(schema instanceof z.ZodBoolean)) {
        let typeHint = '<value>';
        
        if (schema instanceof z.ZodString) {
          typeHint = '<string>';
        } else if (schema instanceof z.ZodNumber) {
          typeHint = '<number>';
        } else if (schema instanceof z.ZodEnum) {
          const values = (schema as any)._def.values;
          typeHint = `<${values.join('|')}>`;
        }
        
        line += ` ${typeHint}`;
      }
      
      // Format the line
      line = line.padEnd(30);
      
      // Add description
      if (def.description) {
        line += def.description;
      }
      
      // Add default value
      if (def.default !== undefined) {
        line += ` (default: ${JSON.stringify(def.default)})`;
      }
      
      // Add required flag
      if (def.required) {
        line += ' (required)';
      }
      
      lines.push(line);
    });
    
    return lines.join('\n');
  }
}