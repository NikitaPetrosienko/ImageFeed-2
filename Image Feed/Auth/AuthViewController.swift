import UIKit
protocol AuthViewControllerDelegate: AnyObject {
    func didAuthenticate(_ vc: AuthViewController)
}

final class AuthViewController: UIViewController {
    weak var delegate: AuthViewControllerDelegate?
    private let oauth2Service = OAuth2Service.shared
    private let tokenStorage = OAuth2TokenStorage()
    
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "ShowWebView", sender: nil)  // Запуск авторизации по нажатию кнопки
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureBackButton()
        
        // Мы удаляем автоматический переход на WebView — только кнопка будет инициировать авторизацию.
        if let token = tokenStorage.token {
            print("Токен найден: \(token)")
            // Если токен есть, можем выполнять дальнейшие действия, если это нужно
        } else {
            print("Токен не найден, требуется авторизация")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let webViewVC = segue.destination as? WebViewViewController {
            webViewVC.delegate = self  // Устанавливаем делегат, чтобы получать код авторизации из WebView
        }
    }
    
    private func configureBackButton() {
        navigationController?.navigationBar.backIndicatorImage = UIImage(named: "nav_back_button")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "nav_back_button")
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = UIColor(named: "ypBlack")
    }
    
    private func saveToken(_ token: String) {
        tokenStorage.token = token
        print("Токен сохранен: \(token)")
        
        // Убедись, что делегат не nil и метод вызывается
        if let delegate = delegate {
            print("Вызывается делегат didAuthenticate")
            delegate.didAuthenticate(self)
        } else {
            print("Делегат не установлен")
        }
    }
}

extension AuthViewController: WebViewViewControllerDelegate {
    // Метод вызывается при успешной аутентификации
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        print("Авторизация успешна, получен код: \(code)")
        oauth2Service.fetchOAuthToken(code: code) { result in
            switch result {
            case .success(let token):
                print("Токен успешно получен: \(token)")
                self.saveToken(token)  // Сохраняем токен для дальнейшего использования
            case .failure(let error):
                print("Ошибка при получении токена: \(error)")
            }
        }
    }
    
    // Метод вызывается при отмене авторизации
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        // Убираем WebViewViewController с экрана
        dismiss(animated: true, completion: nil)
    }
}
