import UIKit
import RenderNeutrino

// MARK: - VCs

class TransitionFromDemoViewController: UIComponentViewController<TransitionFromComponent>, UIViewControllerTransitioningDelegate, UINavigationControllerDelegate {

  override func viewDidLoad() {
    styleNavigationBarComponent(title: "TRANSITION")
    super.viewDidLoad()
  }

  override func buildRootComponent() -> TransitionFromComponent {
    let props = TransitionDemoProps()
    props.onTapAction = {
      let vc = TransitionToDemoViewController()
      vc.transitioningDelegate = self
      self.present(vc, animated: true, completion: nil)
    }
    return context.transientComponent(TransitionFromComponent.self, props: props)
  }

  func animationController(forPresented presented: UIViewController,
                           presenting: UIViewController,
                           source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return Transition()
  }
}

class TransitionToDemoViewController: UIComponentViewController<TransitionToComponent> {
  override func viewDidLoad() {
    view.backgroundColor = S.Palette.primary.color
    canvasView.backgroundColor = view.backgroundColor
    super.viewDidLoad()
  }

  override func buildRootComponent() -> TransitionToComponent {
    let props = TransitionDemoProps()
    props.onTapAction = {
      self.dismiss(animated: true, completion: nil)
    }
    return context.transientComponent(TransitionToComponent.self, props: props)
  }
}

// MARK: - Components

class TransitionDemoProps: UIProps {
  var onTapAction: () -> (Void) = { }
}

class TransitionFromComponent: UIStatelessComponent<TransitionDemoProps> {

  override func render(context: UIContextProtocol) -> UINodeProtocol {
    let container = UINode<UIView> { spec in
      spec.view.yoga.width = spec.canvasSize.width
      spec.view.yoga.height = 80
      spec.view.yoga.flexDirection = .row
      spec.view.onTap { [weak self] _ in
        self?.props.onTapAction()
      }
    }
    let image = UINode<UIView> { spec in
      spec.view.yoga.width = 80
      spec.view.yoga.height = 80
      spec.view.backgroundColor = .red
      spec.view.cornerRadius = 40
      spec.view.makeTransitionable(key: "image", mode: .copy)
    }
    let title = UINode<UILabel> { spec in
      spec.view.textColor = .white
      spec.view.font = UIFont.boldSystemFont(ofSize: 20)
      spec.view.text = "Transition"
      spec.view.yoga.margin = 8
      spec.view.makeTransitionable(key: "title", mode: .copy)
    }
    return container.children([image, title])
  }
}

class TransitionToComponent: UIStatelessComponent<TransitionDemoProps> {

  override func render(context: UIContextProtocol) -> UINodeProtocol {
    let container = UINode<UIView> { spec in
      spec.view.yoga.width = 160
      spec.view.onTap { [weak self] _ in
        self?.props.onTapAction()
      }
    }
    let image = UINode<UIView>() { spec in
      spec.view.yoga.width = 160
      spec.view.yoga.height = 160
      spec.view.backgroundColor = .red
      spec.view.makeTransitionable(key: "image", mode: .copy)
    }
    let title = UINode<UILabel> { spec in
      spec.view.textColor = .white
      spec.view.font = UIFont.boldSystemFont(ofSize: 32)
      spec.view.text = "Transition"
      spec.view.yoga.margin = 8
      spec.view.makeTransitionable(key: "title", mode: .copy)
    }
    return container.children([image, title])
  }
}

// MARK: - Transition

class Transition: UISceneTransition {

  override func transition(context: UIViewControllerContextTransitioning?) {
    super.transition(context: context)
    setupAutoTransition(context: context)

    let targets = transitioningTargets(context: context)
    let navigationBar = fromNavigationBarSnapshot(context: context)
    let duration = transitionDuration(context: context)

    UIView.animate(withDuration: duration, animations: {
      navigationBar.frame.origin.y -= navigationBar.frame.size.height
      for target in targets {
        guard let from = target.0.view else { return }
        guard let to = target.1.view else { return }
        from.frame = to.frame

        switch target.0.key {
        case "image":
          from.cornerRadius = 0
        case "title":
          guard let from = from as? UILabel, let to = to as? UILabel else { break }
          from.alpha = 0
          to.alpha = 1
        default:
          break
        }
      }
    }) { _ in
      self.completeTransition(context: context)
    }
  }
}