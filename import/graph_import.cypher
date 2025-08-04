// ----------------------------
// Neo4j Knowledge-Graph Import
// Place this file in /import (mapped to ./import on host)
// Run inside Neo4j Browser or cypher-shell after the
// container is up and APOC is available.
// ----------------------------

// 1. Schema (idempotent) -----------------------------------
CREATE CONSTRAINT participant_id IF NOT EXISTS
FOR (p:Participant) REQUIRE p.id IS UNIQUE;

CREATE CONSTRAINT interview_id IF NOT EXISTS
FOR (i:Interview) REQUIRE i.id IS UNIQUE;

CREATE CONSTRAINT quote_id IF NOT EXISTS
FOR (q:Quote) REQUIRE q.quoteId IS UNIQUE;

CREATE CONSTRAINT insight_question IF NOT EXISTS
FOR (n:Insight) REQUIRE n.question IS UNIQUE;

CREATE CONSTRAINT signal_id IF NOT EXISTS
FOR (s:Signal) REQUIRE s.signalId IS UNIQUE;

CREATE CONSTRAINT theme_id IF NOT EXISTS
FOR (t:Theme) REQUIRE t.themeId IS UNIQUE;

CREATE CONSTRAINT goal_id IF NOT EXISTS
FOR (g:LearningGoal) REQUIRE g.goalId IS UNIQUE;

// 2. File list ------------------------------------------------
WITH [
  'file:///import/parsed/25cfda76-36e0-4c54-9608-e1a471edf323.json',
  'file:///import/parsed/4b5d43e0-5615-460a-b1a3-08da823d82d3.json',
  'file:///import/parsed/57fa9425-9f6a-4f0c-ab3b-32d15c268e08.json',
  'file:///import/parsed/62d90098-43e5-40f0-948f-ceab3343b59e.json',
  'file:///import/parsed/a9d1132d-0b24-4f33-a31d-289836503cea.json',
  'file:///import/parsed/d8bd7342-e7a3-4125-9d34-8746b116a191.json',
  'file:///import/parsed/e90060bf-b2a9-43af-b252-8167e74d9444.json',
  'file:///import/parsed/f8cfced5-0e16-41aa-bdd5-2ad67c5b3654.json'
] AS files
UNWIND files AS uri
CALL apoc.load.json(uri) YIELD value AS doc
// ---------- Participants -----------------------------------
UNWIND doc.participants AS p
MERGE (person:Participant {id:p.id})
SET  person += apoc.map.clean(p, ['id','interviewIds'], [])
// ---------- Interviews -------------------------------------
WITH doc, p, person
UNWIND doc.interviews AS iv
MERGE (interview:Interview {id:iv.id})
SET  interview += apoc.map.clean(iv,['id','participantId','keyQuoteIds','keyInsights','transcript'],[])
MERGE (person)-[:PARTICIPATED_IN]->(interview)
// ---------- Quotes -----------------------------------------
WITH doc, interview
UNWIND doc.quotes AS q
MERGE (quote:Quote {quoteId:q.quoteId})
SET quote.text = q.text, quote.timestamp=q.timestamp
MERGE (speaker:Participant {id:q.source})
MERGE (speaker)-[:SAID]->(quote)
MERGE (intvw:Interview {id:q.interviewId})
MERGE (intvw)-[:CONTAINS]->(quote)
// ---------- Themes -----------------------------------------
WITH doc
UNWIND doc.themes AS th
MERGE (theme:Theme {themeId:th.themeId})
SET theme.label = th.label,
    theme.type  = th.themeType,
    theme.count = th.count,
    theme.prevalence = th.prevalence,
    theme.strength   = th.strength
// ---------- Insights ---------------------------------------
WITH doc
UNWIND doc.insights AS ins
MERGE (i:Insight {question:ins.question})
SET  i.finding = ins.finding,
     i.mentionCount = ins.mentionCount
FOREACH (qid IN coalesce(ins.quoteIds,[]) |
  MERGE (q:Quote {quoteId:qid})
  MERGE (i)-[:SUPPORTED_BY]->(q)
)
// ---------- Signals ----------------------------------------
WITH doc
UNWIND doc.signals AS sgl
MERGE (s:Signal {signalId:sgl.signalId})
SET s.headline = sgl.headline,
    s.whyItMatters = sgl.whyItMatters,
    s.prevalence = sgl.prevalence
FOREACH (qid IN coalesce(sgl.quoteIds,[]) |
  MERGE (q:Quote {quoteId:qid})
  MERGE (s)-[:SUPPORTED_BY]->(q)
)
// ---------- Learning Goals ---------------------------------
WITH doc
UNWIND doc.learningGoals AS lg
MERGE (g:LearningGoal {goalId:lg.goalId})
SET g.description = lg.description,
    g.coveragePercent = lg.coveragePercent,
    g.confidence = lg.confidence
FOREACH (qid IN coalesce([lg.representativeQuoteId], []) |
  MERGE (q:Quote {quoteId:qid})
  MERGE (g)-[:VALIDATED_BY]->(q)
)
// -----------------------------------------------------------
RETURN 'Import complete for '+uri AS status; 