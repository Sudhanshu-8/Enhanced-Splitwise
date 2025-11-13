# test_improved.py
import easyocr
import cv2
import numpy as np
import re
import sys

# --- Helpers ---
def normalize_amount_token(s):
    """Fix common OCR letter→digit confusions and keep only digits + dot."""
    s = s.replace(',', '.')
    for a, b in [('O','0'),('o','0'),('Q','0'),('q','0'),('I','1'),('l','1'),('|','1'),('B','8')]:
        s = s.replace(a, b)
    s = re.sub(r'[^0-9.]','', s)
    if s.count('.') > 1:
        parts = s.split('.')
        s = parts[0] + '.' + ''.join(parts[1:])
    return s

def extract_amounts_from_text(s):
    """Return float amounts found in a text snippet (tries decimals first)."""
    candidates = re.findall(r'\d+[.,]\d{1,2}', s)
    candidates += re.findall(r'\b\d{1,4}\b', s)  # small integers (likely prices)
    results = []
    for cand in candidates:
        norm = normalize_amount_token(cand)
        try:
            results.append(float(norm))
        except:
            pass
    return results

def build_lines(ocr_results, img_h, prob_thresh=0.35):
    """
    Group OCR tokens into ordered lines using the bbox y-centers.
    Returns a list of line strings (top->bottom).
    """
    tokens = []
    for bbox, text, prob in ocr_results:
        if prob < prob_thresh:
            continue
        xs = [int(p[0]) for p in bbox]
        ys = [int(p[1]) for p in bbox]
        left, right = min(xs), max(xs)
        top, bottom = min(ys), max(ys)
        center_y = (top + bottom) / 2
        tokens.append({'text': text.strip(), 'left': left, 'center_y': center_y, 'top': top, 'bottom': bottom, 'prob': prob})

    if not tokens:
        return []

    tokens_sorted = sorted(tokens, key=lambda t: (t['center_y'], t['left']))
    heights = [t['bottom'] - t['top'] for t in tokens_sorted]
    median_h = np.median(heights) if heights else max(10, img_h * 0.02)
    y_thresh = max(10, median_h * 0.8)

    lines = []
    current = [tokens_sorted[0]]
    for tok in tokens_sorted[1:]:
        cur_center = np.mean([t['center_y'] for t in current])
        if abs(tok['center_y'] - cur_center) <= y_thresh:
            current.append(tok)
        else:
            line_text = ' '.join([t['text'] for t in sorted(current, key=lambda x: x['left'])])
            lines.append(line_text)
            current = [tok]
    line_text = ' '.join([t['text'] for t in sorted(current, key=lambda x: x['left'])])
    lines.append(line_text)
    return lines

def find_vendor(lines):
    for line in lines[:6]:
        if re.search('[A-Za-z]', line) and not re.search(r'\b\d{6,}\b', line):
            return line.strip()
    return lines[0] if lines else "Not found"

def find_phone(lines):
    for line in lines:
        m = re.search(r'(\+?\d{1,3}[-\s]?)?(\d{10})', line)
        if m:
            return m.group(0)
    return "Not found"

def find_date(lines):
    for line in lines:
        m = re.search(r'\b\d{1,2}[\/\-]\d{1,2}[\/\-]\d{2,4}\b', line)
        if m:
            return m.group(0)
    return "Not found"

def parse_items_and_totals(lines):
    items = []
    totals_candidates = []
    for i, line in enumerate(lines):
        low = line.lower()
        amounts = extract_amounts_from_text(line)
        if 'total' in low or 'grand' in low or 'balance' in low or 'amount' in low:
            if amounts:
                totals_candidates.append((i, amounts))
            else:
                if i + 1 < len(lines):
                    next_amounts = extract_amounts_from_text(lines[i+1])
                    if next_amounts:
                        totals_candidates.append((i+1, next_amounts))
        else:
            if amounts:
                price = amounts[-1]
                # remove trailing number to get item name (best-effort)
                name = re.sub(r'(\d+[.,]\d{1,2}|\b\d{1,4}\b)$', '', line).strip()
                items.append((name, price))

    totals_flat = [amt for idx, amts in totals_candidates for amt in amts]
    if not totals_flat:
        all_amounts = []
        for line in lines:
            all_amounts += extract_amounts_from_text(line)
        all_amounts = [a for a in all_amounts if 0 < a < 100000]  # filter ridiculous junk
        probable_total = max(all_amounts) if all_amounts else None
    else:
        probable_total = max(totals_flat)

    return items, totals_flat, probable_total

# --- Main flow ---
def main(image_path):
    reader = easyocr.Reader(['en'])
    img = cv2.imread(image_path)
    if img is None:
        print("Could not open image:", image_path)
        return
    h = img.shape[0]

    print("Running OCR (may download models first)...")
    results = reader.readtext(image_path)

    lines = build_lines(results, h)
    print("\n==== Extracted Lines (top → bottom) ====\n")
    for ln in lines:
        print(ln)

    vendor = find_vendor(lines)
    phone = find_phone(lines)
    date = find_date(lines)
    items, totals_candidates, probable_total = parse_items_and_totals(lines)

    print("\n==== Parsed Summary ====\n")
    print("Vendor:", vendor)
    print("Phone:", phone)
    print("Date:", date)
    print("\nItems:")
    if items:
        for name, price in items:
            print(f" - {name or '(no name)'} : {price:.2f}")
    else:
        print(" No item lines detected")

    print("\nTotal candidates (found near keywords):", totals_candidates)
    print("Likely Grand Total:", f"{probable_total:.2f}" if probable_total else "Not found")

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("Usage: python test_improved.py <receipt_image>")
        sys.exit(1)
    main(sys.argv[1])
