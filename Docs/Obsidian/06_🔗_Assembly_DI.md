---
tags: [assembly, di, dependency-injection, factory]
parent: [[00_📚_IconSearcher_Индекс]]
related: [[02_🏗️_Архитектура_и_Паттерны]], [[05_🎨_MVP_Компоненты]], [[05.2_View_ViewController]], [[05.3_Presenter]]
---

# 🔗 Assembly — Сборка Модуля

## 📖 Оглавление

1. [[#Назначение Assembly|Назначение]]
2. [[#Проблема Создания Зависимостей|Проблема]]
3. [[#Архитектура Assembly|Архитектура]]
4. [[#Реализация IconSearchAssembly|IconSearchAssembly]]
5. [[#Использование в SceneDelegate|SceneDelegate]]
6. [[#Factory Pattern|Factory Pattern]]
7. [[#Best Practices|Best Practices]]
8. [[#Антипаттерны|Антипаттерны]]

---

## 🎯 Назначение Assembly

### Что Решает

```
Проблема: Где создавать граф зависимостей?
├── ❌ В ViewController? → Знает про конкретные классы
├── ❌ В Presenter? → Нарушение SRP
├── ❌ В AppDelegate? → Слишком глобально
└── ✅ В Assembly → Правильно!

Решение: IconSearchAssembly
- Создаёт все зависимости модуля
- Настраивает связи между объектами
- Возвращает готовый ViewController
- Изолирует код сборки от бизнес-логики
```

### Зона Ответственности

| Делает | Не Делает |
|--------|-----------|
| ✅ Создание сервисов | ❌ Не содержит бизнес-логики |
| ✅ Внедрение зависимостей | ❌ Не знает о UI элементах |
| ✅ Настройка связей | ❌ Не отображает данные |
| ✅ Возврат ViewController | ❌ Не работает с UIView |

---

## ⚠️ Проблема Создания Зависимостей

### Без Assembly

```swift
// ❌ Плохо: в SceneDelegate
func scene(_ scene: UIScene, willConnectTo session: UISceneSession) {
    guard let windowScene = (scene as? UIWindowScene) else { return }
    
    // Создание зависимостей вручную
    let networkManager = NetworkManager()
    let iconifyService = IconifyService(networkManager: networkManager)
    let imageLoader = ImageLoader()
    
    let presenter = IconSearchPresenter(
        view: /* ??? */,
        iconService: iconifyService,
        imageLoader: imageLoader
    )
    
    let viewController = IconSearchViewController(presenter: presenter)
    
    // Замыкание цикла (view → presenter)
    // presenter.view = viewController  // Нельзя, view уже создан!
    
    window = UIWindow(windowScene: windowScene)
    window?.rootViewController = viewController
    window?.makeKeyAndVisible()
}

// Проблемы:
// - SceneDelegate знает про конкретные классы
// - Сложно изменить зависимости
// - Трудно тестировать
// - Замыкание цикла сложно реализовать
```

### С Assembly

```swift
// ✅ Хорошо: в SceneDelegate
func scene(_ scene: UIScene, willConnectTo session: UISceneSession) {
    guard let windowScene = (scene as? UIWindowScene) else { return }
    
    // Сборка через Assembly
    let viewController = IconSearchAssembly.assemble()
    
    window = UIWindow(windowScene: windowScene)
    window?.rootViewController = viewController
    window?.makeKeyAndVisible()
}

// Преимущества:
// - SceneDelegate не знает про сервисы
// - Легко изменить зависимости
// - Легко тестировать (mock assembly)
// - Цикл замыкается внутри Assembly
```

---

## 🏗️ Архитектура Assembly

### Положение в Архитектуре

```
┌─────────────────────────────────────────────────────────────┐
│                    Application Layer                        │
│  ┌──────────────────────────────────────────────────────┐  │
│  │ SceneDelegate                                        │  │
│  │                                                       │  │
│  │  Вызов:                                               │  │
│  │  IconSearchAssembly.assemble()                       │  │
│  │                                                       │  │
│  │  Получает:                                            │  │
│  │  IconSearchViewController                            │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                    Assembly Layer                           │
│  ┌──────────────────────────────────────────────────────┐  │
│  │ IconSearchAssembly                                   │  │
│  │                                                       │  │
│  │  Создаёт:                                             │  │
│  │  - NetworkManager                                    │  │
│  │  - IconifyService                                    │  │
│  │  - ImageLoader                                       │  │
│  │  - IconSearchPresenter                               │  │
│  │  - IconSearchViewController                          │  │
│  │                                                       │  │
│  │  Настраивает:                                         │  │
│  │  - Зависимости между объектами                       │  │
│  │  - Замыкание цикла (view ↔ presenter)                │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                    Presentation Layer                       │
│  ┌──────────────────────────────────────────────────────┐  │
│  │ IconSearchViewController                             │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

---

## 💻 Реализация IconSearchAssembly

### Полная Версия

```swift
import UIKit

/// Сборщик модуля поиска иконок.
/// 
/// Отвечает за:
/// - Создание всех зависимостей модуля
/// - Настройку связей между объектами
/// - Возврат готового ViewController
/// 
/// Использование:
/// ```swift
/// let viewController = IconSearchAssembly.assemble()
/// window.rootViewController = viewController
/// ```
final class IconSearchAssembly {
    
    /// Собрать модуль поиска иконок.
    /// - Returns: Готовый к использованию ViewController
    /// 
    /// Процесс сборки:
    /// 1. Создаёт сервисы (NetworkManager, IconifyService, ImageLoader)
    /// 2. Создаёт Presenter с зависимостями
    /// 3. Создаёт ViewController с Presenter
    /// 4. Замыкает цикл View → Presenter
    static func assemble() -> IconSearchViewController {
        
        // MARK: - 1. Создаём сервисы (Service Layer)
        
        let networkManager = NetworkManager(
            memoryCapacity: 50 * 1024 * 1024,
            diskCapacity: 100 * 1024 * 1024
        )
        
        let iconifyService = IconifyService(networkManager: networkManager)
        
        let imageLoader = ImageLoader(
            memoryCapacity: 50 * 1024 * 1024,
            countLimit: 100
        )
        
        // MARK: - 2. Создаём Presenter (Presenter Layer)
        
        // Создаём Presenter без view (view будет создан позже)
        // Используем force unwrap так как уверены, что view будет создан
        var presenter: IconSearchPresenter!
        
        presenter = IconSearchPresenter(
            view: nil,  // Будет установлено после создания VC
            iconService: iconifyService,
            imageLoader: imageLoader
        )
        
        // MARK: - 3. Создаём ViewController (View Layer)
        
        let viewController = IconSearchViewController(presenter: presenter)
        
        // MARK: - 4. Замыкаем цикл
        
        // Устанавливаем view в presenter (weak reference)
        presenter.view = viewController
        
        // MARK: - 5. Возвращаем готовый модуль
        
        return viewController
    }
}
```

---

### Версия с Factory для CellPresenter

```swift
final class IconSearchAssembly {
    
    static func assemble() -> IconSearchViewController {
        
        // 1. Сервисы
        let networkManager = NetworkManager()
        let iconifyService = IconifyService(networkManager: networkManager)
        let imageLoader = ImageLoader()
        
        // 2. Factory для CellPresenter
        let cellPresenterFactory = IconCellPresenterFactory(
            imageLoader: imageLoader
        )
        
        // 3. Presenter
        var presenter: IconSearchPresenter!
        
        presenter = IconSearchPresenter(
            view: nil,
            iconService: iconifyService,
            cellPresenterFactory: cellPresenterFactory
        )
        
        // 4. ViewController
        let viewController = IconSearchViewController(presenter: presenter)
        
        // 5. Замыкание цикла
        presenter.view = viewController
        
        return viewController
    }
}
```

---

## 🏭 Factory Pattern

### IconCellPresenterFactory

```swift
import UIKit

/// Фабрика для создания CellPresenter.
/// 
/// Используется в Presenter для создания презентеров ячеек.
/// Избегает создания ImageLoader для каждой ячейки.
final class IconCellPresenterFactory {
    
    private let imageLoader: ImageLoaderProtocol
    
    init(imageLoader: ImageLoaderProtocol) {
        self.imageLoader = imageLoader
    }
    
    /// Создать CellPresenter для ячейки.
    /// - Parameter delegate: Делегат (ячейка)
    /// - Returns: Новый IconCellPresenter
    func create(delegate: IconCellPresenterDelegate) -> IconCellPresenter {
        return IconCellPresenter(
            delegate: delegate,
            imageLoader: imageLoader
        )
    }
}
```

### Использование в Presenter

```swift
final class IconSearchPresenter {
    
    private let cellPresenterFactory: IconCellPresenterFactory
    private var cellPresenters: [IconCellPresenter] = []
    
    func createCellPresenter(for cell: IconTableViewCell) -> IconCellPresenter {
        let presenter = cellPresenterFactory.create(delegate: cell)
        cellPresenters.append(presenter)
        return presenter
    }
}
```

---

## 🎯 Использование в SceneDelegate

### Полная Реализация

```swift
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        // Сборка модуля через Assembly
        let viewController = IconSearchAssembly.assemble()
        
        // Настройка window
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = viewController
        window?.makeKeyAndVisible()
    }
}
```

---

## ✅ Best Practices

### 1. Статический Метод для Простоты

```swift
// ✅ Хорошо
final class IconSearchAssembly {
    static func assemble() -> IconSearchViewController {
        // ...
    }
}

// Использование:
let vc = IconSearchAssembly.assemble()

// ❌ Плохо
final class IconSearchAssembly {
    init() {}
    
    func assemble() -> IconSearchViewController {
        // ...
    }
}

// Использование:
let assembly = IconSearchAssembly()
let vc = assembly.assemble()  // Лишний объект
```

---

### 2. Замыкание Цикла внутри Assembly

```swift
// ✅ Хорошо
static func assemble() -> IconSearchViewController {
    var presenter: IconSearchPresenter!
    
    presenter = IconSearchPresenter(
        view: nil,  // Weak reference
        iconService: iconifyService
    )
    
    let viewController = IconSearchViewController(presenter: presenter)
    
    // Замыкаем цикл
    presenter.view = viewController
    
    return viewController
}

// ❌ Плохо
static func assemble() -> IconSearchViewController {
    let presenter = IconSearchPresenter(
        view: /* ??? */,  // Не установлено!
        iconService: iconifyService
    )
    
    return IconSearchViewController(presenter: presenter)
}
```

---

### 3. Группировка по Слоям

```swift
// ✅ Хорошо
static func assemble() -> IconSearchViewController {
    // MARK: - 1. Сервисы
    let networkManager = NetworkManager()
    let iconifyService = IconifyService(networkManager: networkManager)
    
    // MARK: - 2. Presenter
    var presenter: IconSearchPresenter!
    presenter = IconSearchPresenter(...)
    
    // MARK: - 3. ViewController
    let viewController = IconSearchViewController(presenter: presenter)
    
    // MARK: - 4. Замыкание цикла
    presenter.view = viewController
    
    return viewController
}

// ❌ Плохо: всё в кучу
static func assemble() -> IconSearchViewController {
    let networkManager = NetworkManager()
    let iconifyService = IconifyService(networkManager: networkManager)
    var presenter: IconSearchPresenter!
    presenter = IconSearchPresenter(...)
    let viewController = IconSearchViewController(presenter: presenter)
    presenter.view = viewController
    return viewController
}
```

---

## ⚠️ Антипаттерны

### 1. Создание в ViewController

```swift
// ❌ Плохо
final class IconSearchViewController: UIViewController {
    
    private let presenter: IconSearchPresenter
    
    init() {
        let networkManager = NetworkManager()
        let iconifyService = IconifyService(networkManager: networkManager)
        
        self.presenter = IconSearchPresenter(
            view: nil,
            iconService: iconifyService
        )
        
        super.init(nibName: nil, bundle: nil)
    }
}

// Проблемы:
// - ViewController знает про конкретные классы
// - Сложно заменить сервисы на mock
// - Нарушение Single Responsibility

// ✅ Хорошо
final class IconSearchViewController: UIViewController {
    
    private let presenter: IconSearchPresenterProtocol
    
    init(presenter: IconSearchPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
}
```

---

### 2. Нет Замыкания Цикла

```swift
// ❌ Плохо
static func assemble() -> IconSearchViewController {
    let presenter = IconSearchPresenter(
        view: nil,  // Никогда не устанавливается!
        iconService: iconifyService
    )
    
    return IconSearchViewController(presenter: presenter)
}

// Результат:
// - presenter.view = nil
// - Вызовы view?.showIcons() не работают
// - Модуль не работает

// ✅ Хорошо
static func assemble() -> IconSearchViewController {
    var presenter: IconSearchPresenter!
    
    presenter = IconSearchPresenter(
        view: nil,
        iconService: iconifyService
    )
    
    let viewController = IconSearchViewController(presenter: presenter)
    
    presenter.view = viewController  // ← Замыкание цикла!
    
    return viewController
}
```

---

### 3. Assembly Знает о UI Элементах

```swift
// ❌ Плохо
final class IconSearchAssembly {
    static func assemble() -> IconSearchViewController {
        let viewController = IconSearchViewController(presenter: presenter)
        
        // Assembly не должен настраивать UI!
        viewController.title = "Поиск иконок"
        viewController.view.backgroundColor = .white
        
        return viewController
    }
}

// ✅ Хорошо
final class IconSearchAssembly {
    static func assemble() -> IconSearchViewController {
        // Только создание зависимостей
        let viewController = IconSearchViewController(presenter: presenter)
        return viewController
    }
}

// Настройка UI в самом ViewController
final class IconSearchViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Поиск иконок"
        view.backgroundColor = .white
    }
}
```

---

## 🧪 Тестирование

### Mock Assembly

```swift
import UIKit

/// Mock Assembly для тестов.
final class MockIconSearchAssembly {
    
    static func assembleWithMockPresenter(
        mockPresenter: IconSearchPresenterProtocol
    ) -> IconSearchViewController {
        return IconSearchViewController(presenter: mockPresenter)
    }
}
```

### Unit Тест Пример

```swift
import XCTest

final class IconSearchAssemblyTests: XCTestCase {
    
    func testAssemble_ReturnsViewController() {
        // When
        let viewController = IconSearchAssembly.assemble()
        
        // Then
        XCTAssertNotNil(viewController)
        XCTAssertNotNil(viewController.view)
    }
    
    func testAssemble_PresenterHasView() {
        // When
        let viewController = IconSearchAssembly.assemble()
        
        // Получаем presenter через reflection (для теста)
        // В реальном коде лучше добавить protocol method для проверки
        // или использовать package access
        
        // Then
        // presenter.view должен быть установлен
    }
}
```

---

## 🔗 Связи

- [[02_🏗️_Архитектура_и_Паттерны]] — Dependency Injection
- [[05.2_View_ViewController]] — создание ViewController
- [[05.3_Presenter]] — создание Presenter
- [[08_⚠️_Типичные_Ошибки]] — антипаттерны DI

---

*Последнее обновление: 2026-02-27*
