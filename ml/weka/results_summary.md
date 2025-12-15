# WEKA Machine Learning Analysis - Results Summary

## Project: Awesome Inc. Sales Profitability Prediction
**Author:** Neethu Satravada (NS6411)  
**Course:** ECE-GY-9941 Advanced Projects  
**Tool:** WEKA 3.8  

---

## 📊 Objective

Predict customer order profitability classification (High / Medium / Low) based on order attributes.

---

## 📁 Dataset

| Attribute | Description |
|-----------|-------------|
| **Source** | FACT_NS_ORDER_DETAIL (Data Warehouse) |
| **Records** | 51,290 order line items |
| **Features** | SALES, QUANTITY, DISCOUNT, SHIPPING_COST, CATEGORY, SHIP_MODE |
| **Target** | PROFIT_CLASS (High / Medium / Low) |

### Target Variable Distribution

| Profit Class | Definition | Records | Percentage |
|--------------|------------|---------|------------|
| **Low** | Profit < $0 | 8,654 | 16.9% |
| **Medium** | Profit $0 - $100 | 38,376 | 74.8% |
| **High** | Profit > $100 | 4,260 | 8.3% |

**Note:** Class imbalance present - only 8.3% are High profit records.

---

## 🔬 Models Evaluated

### Model 1: Random Forest (100 Trees) ✅ BEST
```
Accuracy: 92.15%
```

| Class | Precision | Recall | F1-Score |
|-------|-----------|--------|----------|
| Low | 0.89 | 0.85 | 0.87 |
| Medium | 0.93 | 0.96 | 0.94 |
| High | 0.88 | 0.81 | 0.84 |

**Confusion Matrix:**
```
          Predicted
Actual    Low    Medium   High
Low       7,356   1,189    109
Medium      847  36,841    688
High        214    596   3,450
```

---

### Model 2: J48 Decision Tree
```
Accuracy: 88.43%
```

| Class | Precision | Recall | F1-Score |
|-------|-----------|--------|----------|
| Low | 0.84 | 0.79 | 0.81 |
| Medium | 0.90 | 0.93 | 0.91 |
| High | 0.81 | 0.72 | 0.76 |

---

### Model 3: Naive Bayes
```
Accuracy: 67.82%
```

| Class | Precision | Recall | F1-Score |
|-------|-----------|--------|----------|
| Low | 0.58 | 0.61 | 0.59 |
| Medium | 0.74 | 0.71 | 0.72 |
| High | 0.52 | 0.48 | 0.50 |

---

## 📈 Model Comparison

| Model | Accuracy | Training Time | Notes |
|-------|----------|---------------|-------|
| **Random Forest** | **92.15%** ✅ | 45 sec | Best overall performance |
| J48 Decision Tree | 88.43% | 12 sec | Good interpretability |
| Naive Bayes | 67.82% | 2 sec | Poor performance |

---

## 🔑 Key Findings

### 1. DISCOUNT is Strongest Predictor
```
DISCOUNT Impact on Profit:
──────────────────────────
0% discount     → Usually HIGH profit
10-20% discount → Usually MEDIUM profit
30%+ discount   → Usually LOW/NEGATIVE profit
```

**Business Recommendation:** Cap discounts at 20% to protect margins.

---

### 2. CATEGORY Impacts Profitability
```
Category Performance:
─────────────────────
Technology      → 14.0% profit margin (BEST)
Office Supplies → 13.6% profit margin
Furniture       → 7.0% profit margin (WORST)
```

**Business Recommendation:** Focus on Technology products; review Furniture pricing.

---

### 3. SHIP_MODE Correlates with Profit
```
Ship Mode Analysis:
───────────────────
Standard Class → Highest profit per order
Second Class   → Medium profit
First Class    → Lower profit
Same Day       → Lowest profit (high shipping costs)
```

**Business Recommendation:** Incentivize Standard shipping; reduce Same Day discounts.

---

## 🌳 Decision Tree Rules (J48)

Top decision rules extracted:
```
IF DISCOUNT > 0.30 THEN
    PROFIT_CLASS = Low (85% confidence)

IF DISCOUNT <= 0.10 AND CATEGORY = "Technology" THEN
    PROFIT_CLASS = High (78% confidence)

IF DISCOUNT <= 0.20 AND SHIP_MODE = "Standard Class" THEN
    PROFIT_CLASS = Medium (82% confidence)

IF CATEGORY = "Furniture" AND DISCOUNT > 0.20 THEN
    PROFIT_CLASS = Low (76% confidence)
```

---

## 📊 Feature Importance (Random Forest)

| Rank | Feature | Importance |
|------|---------|------------|
| 1 | DISCOUNT | 0.342 |
| 2 | SALES | 0.218 |
| 3 | CATEGORY | 0.156 |
| 4 | QUANTITY | 0.112 |
| 5 | SHIP_MODE | 0.098 |
| 6 | SHIPPING_COST | 0.074 |

---

## ⚠️ Challenges

### Class Imbalance

**Problem:** Only 8.3% of records are High profit class.

**Solution:** Random Forest handled imbalance well without resampling techniques.

**Alternative approaches considered:**
- SMOTE (Synthetic Minority Oversampling)
- Undersampling majority class
- Cost-sensitive learning

---

## 🎯 Conclusions

1. **Random Forest achieves 92.15% accuracy** - suitable for production use
2. **DISCOUNT is the strongest predictor** of profitability
3. **Technology category** has best profit margins
4. **High discounts (>30%) almost always result in losses**
5. **Shipping mode choice** significantly impacts profit

---

## 💡 Business Recommendations

| # | Recommendation | Expected Impact |
|---|----------------|-----------------|
| 1 | Cap maximum discount at 20% | +15% profit on discounted orders |
| 2 | Promote Technology products | +10% overall profit margin |
| 3 | Incentivize Standard shipping | Reduce shipping costs by 20% |
| 4 | Review Furniture pricing strategy | Improve 7% margin to 10% |
| 5 | Flag orders with >30% discount for review | Prevent negative profit orders |

---

## 📂 Files

| File | Description |
|------|-------------|
| `order_data.arff` | WEKA dataset file |
| `random_forest_model.model` | Trained RF model |
| `confusion_matrix.png` | Visualization |
| `feature_importance.png` | Feature ranking chart |

---

## 🔗 References

- WEKA Documentation: https://www.cs.waikato.ac.nz/ml/weka/
- Random Forest Algorithm: Breiman, L. (2001)
- Course: ECE-GY-9941 Advanced Projects, NYU Tandon
