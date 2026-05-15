# V1 Prompt Templates

維護 claude-code-setup-v1 template 時的常用 prompt 模板。`<!-- ... -->` 為每次使用時替換的佔位符。

**共用結尾（視需要附加到任何 prompt 後）：**

> 若有任何問題請與我討論，若有任何你覺得需要修正的地方請提出來並且給予修正建議，我們再來決定要如何進行優化，使這個 setup 可以達到業界最佳實踐。

## Setup Analysis

### 分析舊版 Setup

```
<!-- setup-v0 --> 是我過去的 claude code setup，
請先分析 <!-- setup-v0 -->，這幾個檔案有沒有需要調整成 hook、command、skill 等，
或是需要優化，使其可以更好的與 setup 中其他檔案整合？
```

### 分析 Skill

```
請審慎分析我的 <!-- SKILL.md -->

- 會不會太複雜？
- 開發流程不符合業界最佳實踐？
- 與 setup 其他內容邏輯抵觸？
- 有冗餘的地方或會降低 CLAUDE 開發能力的部分可以拿掉？
```