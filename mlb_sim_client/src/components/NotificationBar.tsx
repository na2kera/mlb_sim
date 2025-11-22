type Notification = {
  type: "success" | "error";
  text: string;
};

interface NotificationBarProps {
  message: Notification;
  onClose: () => void;
}

export function NotificationBar({ message, onClose }: NotificationBarProps) {
  return (
    <div className={`notification notification--${message.type}`} role="status">
      <span>{message.text}</span>
      <button type="button" onClick={onClose} aria-label="閉じる">
        ×
      </button>
    </div>
  );
}
