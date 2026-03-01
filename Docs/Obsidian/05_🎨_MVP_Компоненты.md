---
tags: [mvp, view, presenter, uiviewcontroller, tableview]
parent: [[00_📚_IconSearcher_Индекс]]
related: [[02_🏗️_Архитектура_и_Паттерны]], [[05.2_Presenter]], [[05.3_CellPresenter]], [[05.4_TableViewCell]]
---

# 🎨 MVP Компоненты — Обзор

## 📖 Оглавление

1. [[#Архитектура MVP|Архитектура MVP]]
2. [[#Компоненты Модуля|Компоненты Модуля]]
3. [[#Схема Взаимодействия|Схема Взаимодействия]]
4. [[#Связи с Другими Модулями|Связи]]
5. [[#Навигация по Заметкам|Навигация]]

---

## 🏛️ Архитектура MVP

### Общая Схема

```
┌─────────────────────────────────────────────────────────────┐
│                    IconSearch Module                        │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌──────────────────────────────────────────────────────┐  │
│  │                    View Layer                        │  │
│  │  ┌────────────────────┐  ┌────────────────────────┐ │  │
│  │  │ IconSearch         │  │ IconSearch             │ │  │
│  │  │ ViewController     │  │ Protocols              │ │  │
│  │  │                    │  │                        │ │  │
│  │  │  - UITextField     │  │  IconSearchViewProtocol│ │  │
│  │  │  - UITableView     │  │  IconSearchPresenter   │ │  │
│  │  │  - LoadingView     │  │  Protocol             │ │  │
│  │  └────────────────────┘  └────────────────────────┘ │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                             │
│  ┌──────────────────────────────────────────────────────┐  │
│  │                 Presenter Layer                      │  │
│  │  ┌────────────────────┐  ┌────────────────────────┐ │  │
│  │  │ IconSearch         │  │ IconCell               │ │  │
│  │  │ Presenter          │  │ Presenter              │ │  │
│  │  │                    │  │                        │ │  │
│  │  │  - Search logic    │  │  - Load image          │ │  │
│  │  │  - Map to VM       │  │  - Cancel on reuse     │ │  │
│  │  │  - Handle errors   │  │  - Delegate callback   │ │  │
│  │  └────────────────────┘  └────────────────────────┘ │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                             │
│  ┌──────────────────────────────────────────────────────┐  │
│  │                   View Layer (Cell)                  │  │
│  │  ┌────────────────────┐  ┌────────────────────────┐ │  │
│  │  │ IconTable          │  │ IconCellPresenter      │ │  │
│  │  │ ViewCell           │  │ Delegate               │ │  │
│  │  │                    │  │                        │ │  │
│  │  │  - ImageView       │  │  imageDidLoad(image)   │ │  │
│  │  │  - Labels          │  │                        │ │  │
│  │  └────────────────────┘  └────────────────────────┘ │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                             │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                   Assembly Layer                            │
│  ┌──────────────────────────────────────────────────────┐  │
│  │ IconSearchAssembly                                   │  │
│  │  - Creates services                                  │  │
│  │  - Creates presenter                                 │  │
│  │  - Creates viewController                            │  │
│  │  - Injects dependencies                              │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

---

## 📦 Компоненты Модуля

### 1. IconSearchProtocols.swift

**Файл:** `Modules/IconSearch/IconSearchProtocols.swift`

**Содержит:**
- `IconSearchViewProtocol` — протокол View
- `IconSearchPresenterProtocol` — протокол Presenter
- `IconViewModel` — модель для отображения

**Статус:** ✅ Готово (требует доработки IconViewModel)

---

### 2. IconSearchViewController.swift

**Файл:** `Modules/IconSearch/View/IconSearchViewController.swift`

**Содержит:**
- `UITextField` для поиска
- `UITableView` для результатов
- `UIActivityIndicatorView` для loading
- Реализация `IconSearchViewProtocol`

**Статус:** ❌ Не реализовано

---

### 3. IconSearchPresenter.swift

**Файл:** `Modules/IconSearch/Presenter/IconSearchPresenter.swift`

**Содержит:**
- Логика поиска
- Маппинг Icon → IconViewModel
- Обработка ошибок
- Навигация (сохранение в галерею)

**Статус:** ⚠️ Реализовано частично (требует рефакторинга)

---

### 4. IconTableViewCell.swift

**Файл:** `Modules/IconSearch/View/IconTableViewCell.swift`

**Содержит:**
- `UIImageView` для иконки
- `UILabel` для размера
- `UILabel` для тегов
- `prepareForReuse()`
- `IconCellPresenterDelegate`

**Статус:** ❌ Не реализовано

---

### 5. IconCellPresenter.swift

**Файл:** `Modules/IconSearch/Presenter/IconCellPresenter.swift`

**Содержит:**
- Загрузка изображения через `ImageLoader`
- Отмена загрузки при reuse
- Delegate callback с результатом

**Статус:** ❌ Не реализовано

---

### 6. IconSearchAssembly.swift

**Файл:** `Modules/IconSearch/Assembly/IconSearchAssembly.swift`

**Содержит:**
- Создание всех зависимостей
- Внедрение зависимостей
- Возврат готового ViewController

**Статус:** ❌ Не реализовано

---

## 🔗 Схема Взаимодействия

### Поиск Иконок

```
┌──────────────────────────────────────────────────────────────┐
│  1. Пользователь вводит запрос                              │
│                                                             │
│     ┌──────────────┐                                        │
│     │ UITextField  │                                        │
│     └──────┬───────┘                                        │
│            │ textDidChange                                   │
│            ▼                                                 │
│  ┌──────────────────┐                                        │
│  │ ViewController   │                                        │
│  └────────┬─────────┘                                        │
│           │ searchButtonTapped(query:)                       │
│           ▼                                                  │
│  ┌──────────────────┐                                        │
│  │ Presenter        │                                        │
│  └────────┬─────────┘                                        │
│           │ searchIcons(query:)                              │
│           ▼                                                  │
│  ┌──────────────────┐                                        │
│  │ IconService      │                                        │
│  └──────────────────┘                                        │
└──────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────┐
│  2. Получение результата                                    │
│                                                             │
│  ┌──────────────────┐                                        │
│  │ IconService      │                                        │
│  └────────┬─────────┘                                        │
│           │ completion([Icon])                               │
│           ▼                                                  │
│  ┌──────────────────┐                                        │
│  │ Presenter        │                                        │
│  │ mapToViewModels()│                                        │
│  └────────┬─────────┘                                        │
│           │ showIcons([IconViewModel])                       │
│           ▼                                                  │
│  ┌──────────────────┐                                        │
│  │ ViewController   │                                        │
│  │ tableView.reload │                                        │
│  └──────────────────┘                                        │
└──────────────────────────────────────────────────────────────┘
```

### Загрузка Картинки в Ячейке

```
┌──────────────────────────────────────────────────────────────┐
│  3. Отображение иконки в ячейке                             │
│                                                             │
│  ┌──────────────────┐                                        │
│  │ ViewController   │                                        │
│  │ cellForRowAt:    │                                        │
│  └────────┬─────────┘                                        │
│           │ configure(with:viewModel, presenter:)            │
│           ▼                                                  │
│  ┌──────────────────┐                                        │
│  │ TableViewCell    │                                        │
│  └────────┬─────────┘                                        │
│           │ loadImage(from:)                                 │
│           ▼                                                  │
│  ┌──────────────────┐                                        │
│  │ CellPresenter    │                                        │
│  └────────┬─────────┘                                        │
│           │ loadImage(from:)                                 │
│           ▼                                                  │
│  ┌──────────────────┐                                        │
│  │ ImageLoader      │                                        │
│  │ 1. Check cache   │                                        │
│  │ 2. Load from net │                                        │
│  └────────┬─────────┘                                        │
│           │ completion(UIImage)                              │
│           ▼                                                  │
│  ┌──────────────────┐                                        │
│  │ CellPresenter    │                                        │
│  └────────┬─────────┘                                        │
│           │ imageDidLoad(image)                              │
│           ▼                                                  │
│  ┌──────────────────┐                                        │
│  │ TableViewCell    │                                        │
│  │ imageView.image  │                                        │
│  └──────────────────┘                                        │
└──────────────────────────────────────────────────────────────┘
```

---

## 📊 Связи с Другими Модулями

### Зависимости Модуля IconSearch

```
┌─────────────────────────────────────────────────────────────┐
│              IconSearch Module                              │
│                                                             │
│  Зависит от:                                                │
│  ┌──────────────────────────────────────────────────────┐  │
│  │ Services Layer                                       │  │
│  │  - IconServiceProtocol                               │  │
│  │  - ImageLoaderProtocol                               │  │
│  │  - Cache<URL, UIImage>                               │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                             │
│  Использует модели:                                         │
│  ┌──────────────────────────────────────────────────────┐  │
│  │ Models                                               │  │
│  │  - Icon (Domain)                                     │  │
│  │  - IconViewModel (Presentation)                      │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

---

## 🗺️ Навигация по Заметкам

### Детальные Заметки по Компонентам

| Компонент | Заметка | Статус |
|-----------|---------|--------|
| **Протоколы** | [[05.1_Protocols_Протоколы]] | ✅ |
| **ViewController** | [[05.2_View_ViewController]] | ❌ |
| **Presenter** | [[05.3_Presenter]] | ⚠️ |
| **CellPresenter** | [[05.4_CellPresenter]] | ❌ |
| **TableViewCell** | [[05.5_TableViewCell]] | ❌ |
| **Assembly** | [[06_🔗_Assembly_DI]] | ❌ |

---

## 📋 Чеклист Реализации

### Часть 1: Протоколы
- [x] IconSearchViewProtocol
- [x] IconSearchPresenterProtocol
- [ ] IconCellPresenterDelegate

### Часть 2: View
- [ ] IconSearchViewController
- [ ] IconTableViewCell

### Часть 3: Presenter
- [x] IconSearchPresenter (существует)
- [ ] IconSearchPresenter (рефакторинг)
- [ ] IconCellPresenter

### Часть 4: Assembly
- [ ] IconSearchAssembly

### Часть 5: Интеграция
- [ ] SceneDelegate вызов Assembly

---

## 🔗 Связи

- [[02_🏗️_Архитектура_и_Паттерны]] — общая архитектура MVP
- [[06_🔗_Assembly_DI]] — сборка модуля
- [[08_⚠️_Типичные_Ошибки]] — ошибки в MVP

---

*Последнее обновление: 2026-02-27*
