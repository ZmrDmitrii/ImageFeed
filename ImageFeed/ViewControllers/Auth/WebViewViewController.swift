//
//  WebViewViewController.swift
//  ImageFeed
//
//  Created by Дмитрий Замараев on 4/9/24.
//
import WebKit

final class WebViewViewController: UIViewController {
    
    // MARK: - IB Outlets
    @IBOutlet private weak var backwardButton: UIButton!
    @IBOutlet private weak var webView: WKWebView!
    @IBOutlet weak var progressView: UIProgressView!
    
    // MARK: - Public Properties
    weak var delegate: WebViewViewControllerDelegate?
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        backwardButton.setTitle("", for: .normal)
        loadAuthView()
        webView.navigationDelegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        webView.addObserver(
            self,
            forKeyPath: #keyPath(WKWebView.estimatedProgress),
            options: .new,
            context: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        webView.removeObserver(
            self,
            forKeyPath: #keyPath(WKWebView.estimatedProgress),
            context: nil)
    }
    
    // MARK: - Override Methods
    override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey : Any]?,
        context: UnsafeMutableRawPointer?
    ) {
        if keyPath == #keyPath(WKWebView.estimatedProgress) {
            updateProgress()
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    // MARK: - IB Action
    @IBAction private func didTapBackwardButton(_ sender: Any) {
        delegate?.webViewViewControllerDidCancel(self)
    }
    
    // MARK: - Private Methods
    private func loadAuthView() {
        guard var urlComponents = URLComponents(string: Constants.unsplashAuthorizeURLString) else {
            assertionFailure("Error: failed to get unsplashAuthorizeURLString")
            return
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: Constants.accessScope)
        ]
        
        guard let url = urlComponents.url else {
            assertionFailure("Error: failed to get url")
            return
        }
        
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    // Функция code(from:) проверяет, есть ли в URL, на который хочет перейти пользователь параметр code
    // Параметр code используется для авторизации в OAuth
    private func code(from navigationAction: WKNavigationAction) -> String? {
        if
            // Из объекта navigationAction достаем URL, по которому пользователь собирается перейти
            let url = navigationAction.request.url,
            // Превращаем этот URL в структуру URLComponents, чтобы проще было работать с его компонентами
            let urlComponents = URLComponents(string: url.absoluteString),
            // Проверяем соответствует ли путь в URL тому, который мы ожидаем для получения кода авторизации
            urlComponents.path == "/oauth/authorize/native",
            // Проверяем есть ли у URL параметры (query items), которые могли бы содержать код
            let items = urlComponents.queryItems,
            // Среди всех параметров (query items) ищем такой, у которого имя "code"
            let codeItem = items.first(where: { $0.name == "code" })
        {
            // Если параметр с именем "code" найден - возвращаем его
            return codeItem.value
        } else {
            // Если параметр с именем "code" не найден - возвращаем nil
            return nil
        }
    }
    
    private func updateProgress() {
        progressView.progress = Float(webView.estimatedProgress)
        progressView.isHidden = fabs(webView.estimatedProgress - 1.0) <= 0.0001
    }
}

// MARK: - WKNavigationDelegate
extension WebViewViewController: WKNavigationDelegate {
    // Метод decidePolicyFor вызывается, когда пользователь делает навигационное действие в WKWebView (клик по ссылке / кнопке)
    // В этом методе мы решаем, что делать с запросом на действие пользователя: запретить или разрешить
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        // Функция code(from:) проверяет, есть ли в URL, на который хочет перейти пользователь, параметр "code"
        if let code = code(from: navigationAction) {
            // Если параметр с именем "code" найден в URL - навигация отменятся (.cancel) - пользователь авторизовался
            delegate?.webViewViewController(self, didAuthenticateWithCode: code)
            decisionHandler(.cancel)
        } else {
            // Если параметр с именем "code" не найден в URL - разрешаем навигацию дальше - пользователь просто переходит на другую страницу
            decisionHandler(.allow)
        }
    }
}
