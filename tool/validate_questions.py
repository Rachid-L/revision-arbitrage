#!/usr/bin/env python3
import json
from pathlib import Path

path = Path(__file__).resolve().parents[1] / 'assets' / 'data' / 'questions.json'
questions = json.loads(path.read_text(encoding='utf-8'))
required = {'id', 'type', 'category', 'motif', 'answer', 'explanation', 'season'}
valid_answers = {'CFD', 'CFI', 'CJ', 'CR'}
valid_types = {'reprise', 'discipline'}

errors = []
ids = set()
for index, q in enumerate(questions, 1):
    missing = required - q.keys()
    if missing:
        errors.append(f'Question #{index}: champs manquants: {sorted(missing)}')
    if q.get('id') in ids:
        errors.append(f"ID dupliqué: {q.get('id')}")
    ids.add(q.get('id'))
    if q.get('answer') not in valid_answers:
        errors.append(f"Question {q.get('id')}: réponse invalide")
    if q.get('category') != q.get('answer'):
        errors.append(f"Question {q.get('id')}: category et answer diffèrent")
    if q.get('type') not in valid_types:
        errors.append(f"Question {q.get('id')}: type invalide")
    if q.get('type') == 'reprise' and q.get('answer') not in {'CFD', 'CFI'}:
        errors.append(f"Question {q.get('id')}: une reprise doit être CFD/CFI")
    if q.get('type') == 'discipline' and q.get('answer') not in {'CJ', 'CR'}:
        errors.append(f"Question {q.get('id')}: une sanction doit être CJ/CR")

if errors:
    print('\n'.join(errors))
    raise SystemExit(1)

print(f'OK — {len(questions)} questions valides, {len(ids)} IDs uniques.')
