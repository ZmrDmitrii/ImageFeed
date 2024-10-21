//
//  WebViewViewController.swift
//  ImageFeed
//
//  Created by Дмитрий Замараев on 4/9/24.
//
import WebKit

protocol WebViewViewControllerProtocol: AnyObject {
    var presenter: WebViewPresenterProtocol? { get set }
    func load(request: URLRequest)
    func setProgressValue(_ newValue: Float)
    func setProgressHidden(_ isHidden: Bool)
}

final class WebViewViewController: UIViewController & WebViewViewControllerProtocol {
    
    // MARK: - IB Outlets
    
    @IBOutlet private weak var backwardButton: UIButton!
    @IBOutlet private weak var webView: WKWebView!
    @IBOutlet weak var progressView: UIProgressView!
    
    // MARK: - Internal Properties
    
    weak var delegate: WebViewViewControllerDelegate?
    var presenter: WebViewPresenterProtocol?
    
    // MARK: - Private Properties
    
    private var estimatedProgressObservation: NSKeyValueObservation?
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backwardButton.setTitle("", for: .normal)
        presenter?.viewDidLoad()
        webView.navigationDelegate = self
        
        estimatedProgressObservation = webView.observe(
            \.estimatedProgress,
             options: []
        ) { [weak self] _, _ in
            guard let self else { return }
            presenter?.didUpdateProgressValue(webView.estimatedProgress)
        }
    }
    
    // MARK: - IB Action
    
    @IBAction private func didTapBackwardButton(_ sender: Any) {
        delegate?.webViewViewControllerDidCancel(self)
    }
    
    // MARK: - Internal Methods
    
    func load(request: URLRequest) {
        webView.load(request)
    }
    
    func setProgressValue(_ newValue: Float) {
        progressView.progress = newValue
    }
    
    func setProgressHidden(_ isHidden: Bool) {
        progressView.isHidden = isHidden
    }
    
    // MARK: - Private Methods
    
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
        guard let code = code(from: navigationAction) else {
            // Если параметр с именем "code" не найден в URL - разрешаем навигацию дальше - пользователь просто переходит на другую страницу
            decisionHandler(.allow)
            return
        }
        // Если параметр с именем "code" найден в URL - навигация отменятся (.cancel) - пользователь авторизовался
        delegate?.webViewViewController(self, didAuthenticateWithCode: code)
        decisionHandler(.cancel)
    }
}
