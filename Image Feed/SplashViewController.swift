import UIKit

final class SplashViewController: UIViewController {

    private let storage = OAuth2TokenStorage()

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        storage.clearToken()  // Очищаем токен для тестирования, можно убрать позже

        // Проверяем, есть ли токен в хранилище
        if let token = storage.token {
            print("Токен найден: \(token)")
            switchToTabBarController()  // Перенаправляем в галерею
        } else {
            showAuthController()  // Программный переход на экран авторизации
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowAuthScreen" {
            guard let navController = segue.destination as? UINavigationController,
                  let authViewController = navController.viewControllers.first as? AuthViewController else {
                return
            }
            authViewController.delegate = self  // Устанавливаем делегат здесь
        }
    }
    // Метод для переключения на TabBarController (галерею)
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid window configuration")
            return
        }
        
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()  // Убедись, что добавил этот метод для отображения окна
    }
    // Программный переход на AuthViewController
    private func showAuthController() {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid window configuration")
            return
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let authNavController = storyboard.instantiateViewController(withIdentifier: "AuthNavigationController") as! UINavigationController
        
        if let authViewController = authNavController.viewControllers.first as? AuthViewController {
            authViewController.delegate = self  // Устанавливаем делегат здесь!
        }
        
        window.rootViewController = authNavController
        window.makeKeyAndVisible() // Показываем новый rootViewController
    }
}
extension SplashViewController: AuthViewControllerDelegate {
    func didAuthenticate(_ vc: AuthViewController) {
        vc.dismiss(animated: true) { [weak self] in
            print("Переход на TabBarController")  // Убедимся, что вызывается
            self?.switchToTabBarController()
        }
    }
}
