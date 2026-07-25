# 🤖 Applied AI & Generative AI Portfolio

This directory tracks my step-by-step progression from basic Large Language Model (LLM) API integration to building production-grade Retrieval-Augmented Generation (RAG) applications and autonomous AI agents.

---

## 🎯 Learning & Implementation Roadmap

| Module | Focus Area | Key Concepts & Frameworks | Status |
| :--- | :--- | :--- | :--- |
| **`01_LLM_APIs_&_Prompting`** | LLM Foundations | OpenAI API, Gemini API, System Prompts, Structured Outputs (JSON Mode, Pydantic) | ⏳ In Progress |
| **`02_RAG_Knowledge_Bases`** | Retrieval-Augmented Gen | Vector Embeddings, Chunking Strategies, Vector Databases (pgvector / Chroma), LangChain | 📑 Planned |
| **`03_AI_Agents_&_Tools`** | Autonomous Systems | Function Calling, Tool Use, LangGraph, ReAct Agent Loops, State Management | 📑 Planned |
| **`04_FineTuning_&_Evaluation`** | Optimization & Quality | Model Evaluation, Guardrails, LoRA / QLoRA Fine-tuning, Quantization | 📑 Planned |

---

## 🚀 Projects Overview

### 1. Structured Data Extraction Agent (`01_LLM_APIs_&_Prompting`)
* **Objective:** Extract clean, structured JSON from unstructured raw text logs and PDF reports.
* **Tech Stack:** Python, OpenAI / Gemini API, Pydantic, Instructor.
* **Key Outcome:** Handles messy text input and guarantees schema enforcement for downstream analytical pipelines.

### 2. RAG Document Q&A System (`02_RAG_Knowledge_Bases`)
* **Objective:** Build a contextual search and Q&A engine over domain-specific PDF documentation with exact source citations.
* **Tech Stack:** Python, PostgreSQL (`pgvector`), OpenAI Embeddings, LangChain.
* **Key Outcome:** Sub-2-second latency document retrieval with zero-hallucination guardrails.

---

## 🛠️ Tech Stack & Tools

* **Languages:** Python, SQL
* **LLM APIs:** OpenAI, Google Gemini, Anthropic Claude, Ollama (Local)
* **Vector DBs:** PostgreSQL (`pgvector`), ChromaDB
* **Frameworks:** LangChain, LlamaIndex, Pydantic
* **Deployment & UI:** Streamlit, FastAPI, Docker

---

## 📌 References & Learning Resources
* [OpenAI Cookbook & Documentation](https://cookbook.openai.com/)
* [LangChain & LlamaIndex Official Documentation](https://python.langchain.com/)
* [Pinecone Learning Center: Vector Embeddings & RAG](https://www.pinecone.io/learn/)
