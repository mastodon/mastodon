追加API
============

## Contents

- [Methods](#methods)
  - [アンケート](#enquete)
  
___

## Methods

### Enquete
by [あさくら様](https://knzk.me/@asakura_dev)

#### アンケート付きトゥートの投稿:

    POST /api/v1/statuses
    
Form data **(これらと一緒にstatus等も必要です)**:

| Field             | Description                                                              | Optional   |
| ----------------- | ------------------------------------------------------------------------ | ---------- |
| `isEnquete`       | アンケートを投稿する場合にtrue                                             | no         |
| `enquete_duration`| 投票期間を秒数で指定 (30~86400)                                            | no         |
| `enquete_items`   | 15文字以内の項目を2~4つの配列で指定                                         | no         |

#### アンケートの投票:

    POST /api/v1/votes/:id
    
Form data:

| Field             | Description                                                              | Optional   |
| ----------------- | ------------------------------------------------------------------------ | ---------- |
| `item_index`      | 投票する項目を0~4で指定(4の場合は :thinking: )                             | no         |
