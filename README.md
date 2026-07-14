# WBDarkstore

## Настройка API-токена перед запуском

Файл с токеном (`Token.swift`) не хранится в репозитории — он в `.gitignore`, чтобы не публиковать чувствительные данные.

### Как настроить:

1. Скопируйте `WBDarkstore/Services/Token.swift.example` в `WBDarkstore/Services/Token.swift`:
```bash
   cp WBDarkstore/Services/Token.swift.example WBDarkstore/Services/Token.swift
```

2. Откройте `Token.swift` и вставьте реальный токен вместо плейсхолдера:
```swift
   enum Secrets {
       static let apiToken = "ваш_реальный_токен_здесь"
   }
```

3. В Xcode добавьте `Token.swift` в проект (если не подхватился автоматически): ПКМ на папке `Services` → **Add Files to "WBDarkstore"...** → выберите `Token.swift`, убедитесь, что стоит галочка **Target: WBDarkstore**.

4. Соберите и запустите (`Cmd+R`).
