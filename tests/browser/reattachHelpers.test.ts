import { describe, expect, test, vi } from "vitest";
import {
  alignPromptEchoPair,
  buildPromptEchoMatcher,
  readPromptPreviewTurnIndex,
} from "../../src/browser/reattachHelpers.ts";

describe("alignPromptEchoPair", () => {
  test("aligns answer text when text is a prompt echo", () => {
    const matcher = buildPromptEchoMatcher("Echo prompt");
    expect(matcher).not.toBeNull();
    const result = alignPromptEchoPair("Echo prompt", "Real answer", matcher);
    expect(result.answerText).toBe("Real answer");
    expect(result.answerMarkdown).toBe("Real answer");
    expect(result.isEcho).toBe(false);
  });

  test("aligns answer markdown when markdown is a prompt echo", () => {
    const matcher = buildPromptEchoMatcher("Echo prompt");
    expect(matcher).not.toBeNull();
    const result = alignPromptEchoPair("Real answer", "Echo prompt", matcher);
    expect(result.answerText).toBe("Real answer");
    expect(result.answerMarkdown).toBe("Real answer");
    expect(result.isEcho).toBe(false);
  });

  test("keeps echo flag when both text and markdown are prompt echoes", () => {
    const matcher = buildPromptEchoMatcher("Echo prompt");
    expect(matcher).not.toBeNull();
    const result = alignPromptEchoPair("Echo prompt", "Echo prompt", matcher);
    expect(result.isEcho).toBe(true);
  });
});

describe("readPromptPreviewTurnIndex", () => {
  test("returns the matched user turn index from the browser page", async () => {
    const evaluate = vi.fn().mockResolvedValue({ result: { value: 7 } });

    await expect(
      readPromptPreviewTurnIndex({ evaluate } as never, "ORACLE_EXISTING_CHAT_DEMO_TURN1"),
    ).resolves.toBe(7);

    expect(evaluate).toHaveBeenCalledWith(
      expect.objectContaining({
        expression: expect.stringContaining('data-message-author-role="user"'),
        returnByValue: true,
      }),
    );
  });

  test("skips empty prompt previews", async () => {
    const evaluate = vi.fn();

    await expect(readPromptPreviewTurnIndex({ evaluate } as never, "   ")).resolves.toBeNull();

    expect(evaluate).not.toHaveBeenCalled();
  });
});
