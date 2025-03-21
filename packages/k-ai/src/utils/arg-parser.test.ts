import { describe, it, expect } from 'vitest';
import { z } from 'zod';
import { Command, CliError } from './arg-parser';

describe('Command', () => {
  // Basic command creation and help
  it('should create a command with description', () => {
    const cmd = new Command({ description: 'Test command' });
    expect(cmd.help()).toContain('Test command');
  });

  // Boolean flags
  it('should parse boolean flags', () => {
    const cmd = new Command({ description: 'Test' })
      .arg('verbose', {
        schema: z.boolean().default(false),
        description: 'Enable verbose output',
        short: 'v'
      });

    // Test with long form
    const result1 = cmd.parse(['--verbose']);
    expect(result1.args.verbose.value).toBe(true);
    expect(result1.args.verbose.provided).toBe(true);

    // Test with short form
    const result2 = cmd.parse(['-v']);
    expect(result2.args.verbose.value).toBe(true);
    expect(result2.args.verbose.provided).toBe(true);

    // Test without flag
    const result3 = cmd.parse([]);
    expect(result3.args.verbose.value).toBe(false);
    expect(result3.args.verbose.provided).toBe(false);
  });

  // String arguments
  it('should parse string arguments', () => {
    const cmd = new Command({ description: 'Test' })
      .arg('name', {
        schema: z.string(),
        description: 'Your name',
        short: 'n'
      });

    // Test with long form and equals
    const result1 = cmd.parse(['--name=John']);
    expect(result1.args.name.value).toBe('John');
    expect(result1.args.name.provided).toBe(true);

    // Test with long form and space
    const result2 = cmd.parse(['--name', 'Jane']);
    expect(result2.args.name.value).toBe('Jane');
    expect(result2.args.name.provided).toBe(true);

    // Test with short form and space
    const result3 = cmd.parse(['-n', 'Alice']);
    expect(result3.args.name.value).toBe('Alice');
    expect(result3.args.name.provided).toBe(true);

    // Test with short form and attached value
    const result4 = cmd.parse(['-nBob']);
    expect(result4.args.name.value).toBe('Bob');
    expect(result4.args.name.provided).toBe(true);
  });

  // Number arguments
  it('should parse and validate number arguments', () => {
    const cmd = new Command({ description: 'Test' })
      .arg('count', {
        schema: z.number().int().positive(),
        description: 'Count of items',
        short: 'c'
      });

    // Valid number
    const result1 = cmd.parse(['--count=10']);
    expect(result1.args.count.value).toBe(10);
    expect(result1.args.count.provided).toBe(true);

    // Invalid number should throw
    expect(() => cmd.parse(['--count=abc'])).toThrow(CliError);
    expect(() => cmd.parse(['--count=0'])).toThrow(CliError);
    expect(() => cmd.parse(['--count=-5'])).toThrow(CliError);
  });

  // Default values
  it('should use default values when not provided', () => {
    const cmd = new Command({ description: 'Test' })
      .arg('port', {
        schema: z.number().int().positive(),
        description: 'Port number',
        short: 'p',
        default: 3000
      });

    const result = cmd.parse([]);
    expect(result.args.port.value).toBe(3000);
    expect(result.args.port.provided).toBe(false);
  });

  // Required arguments
  it('should enforce required arguments', () => {
    const cmd = new Command({ description: 'Test' })
      .arg('file', {
        schema: z.string(),
        description: 'File path',
        required: true
      });

    expect(() => cmd.parse([])).toThrow(CliError);
    
    const result = cmd.parse(['--file', 'test.txt']);
    expect(result.args.file.value).toBe('test.txt');
  });

  // Multiple arguments
  it('should parse multiple arguments', () => {
    const cmd = new Command({ description: 'Test' })
      .arg('verbose', {
        schema: z.boolean().default(false),
        short: 'v'
      })
      .arg('file', {
        schema: z.string(),
        short: 'f'
      })
      .arg('count', {
        schema: z.number().int(),
        default: 1,
        short: 'c'
      });

    const result = cmd.parse(['-v', '--file=test.txt', '-c', '5']);
    expect(result.args.verbose.value).toBe(true);
    expect(result.args.file.value).toBe('test.txt');
    expect(result.args.count.value).toBe(5);
  });

  // Positional arguments
  it('should collect positional arguments', () => {
    const cmd = new Command({ description: 'Test' })
      .arg('verbose', {
        schema: z.boolean().default(false),
        short: 'v'
      });

    const result = cmd.parse(['-v', 'file1.txt', 'file2.txt']);
    expect(result.args.verbose.value).toBe(true);
    expect(result.positional).toEqual(['file1.txt', 'file2.txt']);
  });

  // Double dash separator
  it('should handle double dash separator for rest arguments', () => {
    const cmd = new Command({ description: 'Test' })
      .arg('verbose', {
        schema: z.boolean().default(false),
        short: 'v'
      });

    const result = cmd.parse(['-v', 'file.txt', '--', '--not-a-flag', 'other-arg']);
    expect(result.args.verbose.value).toBe(true);
    expect(result.positional).toEqual(['file.txt']);
    expect(result.rest).toEqual(['--not-a-flag', 'other-arg']);
  });

  // Error accumulation
  it('should accumulate errors', () => {
    const cmd = new Command({ description: 'Test' })
      .arg('count', {
        schema: z.number().int().positive(),
        short: 'c'
      })
      .arg('mode', {
        schema: z.enum(['fast', 'slow']),
        short: 'm'
      });

    try {
      cmd.parse(['--count=abc', '--mode=invalid']);
      expect(true).toBe(false); // Should not reach here
    } catch (error) {
      expect(error).toBeInstanceOf(CliError);
      if (error instanceof CliError) {
        expect(error.errors.length).toBe(2);
        expect(error.errors[0]).toContain('count');
        expect(error.errors[1]).toContain('mode');
      }
    }
  });

  // Multiple short flags combined
  it('should handle multiple short boolean flags combined', () => {
    const cmd = new Command({ description: 'Test' })
      .arg('verbose', {
        schema: z.boolean().default(false),
        short: 'v'
      })
      .arg('quiet', {
        schema: z.boolean().default(false),
        short: 'q'
      })
      .arg('debug', {
        schema: z.boolean().default(false),
        short: 'd'
      });

    // Pass non-boolean flag first
    expect(() => cmd.parse(['-vq'])).not.toThrow();
    
    const result = cmd.parse(['-vq']);
    expect(result.args.verbose.value).toBe(true);
    expect(result.args.quiet.value).toBe(true);
    expect(result.args.debug.value).toBe(false);
  });

  // Enum arguments
  it('should parse enum arguments', () => {
    const cmd = new Command({ description: 'Test' })
      .arg('mode', {
        schema: z.enum(['fast', 'slow', 'auto']),
        description: 'Operating mode',
        default: 'auto'
      });

    const result1 = cmd.parse(['--mode=fast']);
    expect(result1.args.mode.value).toBe('fast');

    expect(() => cmd.parse(['--mode=turbo'])).toThrow(CliError);
    
    const result2 = cmd.parse([]);
    expect(result2.args.mode.value).toBe('auto');
  });
});