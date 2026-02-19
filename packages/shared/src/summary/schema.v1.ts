import { z } from "zod";

export const SummarySchemaV1 = z.object({
  schema_version: z.literal(1),
  importance: z.enum(["low", "med", "high"]),
  bucket: z.enum(["new", "needs_response", "waiting_response", "archived"]),
  one_liner: z.string().min(1).max(200),
  bullets: z.array(z.string().min(1).max(200)).max(8),
  suggested_reply: z.string().max(2000).nullable(),
  tags: z.array(z.string().min(1).max(32)).max(6),
});

export type SummaryV1 = z.infer<typeof SummarySchemaV1>;
