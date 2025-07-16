import { GoogleGenAI } from "@google/genai";

const NEWLINE = "$NEWLINE$";
const ai = new GoogleGenAI({ apiKey: process.env.GEMINI_API_KEY });

export const dynamic = "force-dynamic";

export const GET = async () => {
  const responseStream = new TransformStream();
  const writer = responseStream.writable.getWriter();
  const encoder = new TextEncoder();

  const completion = await ai.models.generateContentStream({
    model: 'gemini-2.0-flash-001',
    contents: 'give me some well known hotel booking platforms'
  });

  (async () => {
    for await (const chunk of completion) {
      const content = chunk.text;
      if (content !== undefined && content !== null) {
        // avoid newlines getting messed up
        const contentWithNewlines = content.replace(/\n/g, NEWLINE);
        await writer.write(
          encoder.encode(`event: token\ndata: ${contentWithNewlines}\n\n`)
        );
      }
    }

    await writer.write(encoder.encode(`event: finished\ndata: true\n\n`));
    await writer.close();
  })();
  return new Response(responseStream.readable, {
    headers: {
      "Content-Type": "text/event-stream",
      "Cache-Control": "no-cache, no-transform",
    },
  });
};
