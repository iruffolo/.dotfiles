from libqtile.command.base import expose_command
from libqtile.layout.base import _SimpleLayoutBase


class UltraWide(_SimpleLayoutBase):

    defaults = [
        ("margin", 10, "Margin of the layout (int or list of ints [N E S W])"),
        ("border_focus", "#19E0C8", "Border colour(s) for the window when focused"),
        ("border_normal", "#000000", "Border colour(s) for window when not focused"),
        ("border_width", 0, "Border width."),
        ("sizing_mode", "absolute", "Method to determine the size of the window rect"),
        ("width", 1280, "The window rect's width."),
        ("height", 720, "The window rect's height."),
        ("grow_amount", 100, "Amount by which to grow/shrink the window."),
    ]

    def __init__(self, **config):
        super().__init__(self, **config)
        self.add_defaults(UltraWide.defaults)

    def configure(self, client, screen_rect):
        if self.clients and client is self.clients.current_client:
            w = (
                screen_rect.width * self.width
                if self.sizing_mode == "relative"
                else self.width
            ) - self.border_width * 2
            h = (
                screen_rect.height * self.height
                if self.sizing_mode == "relative"
                else self.height
            ) - self.border_width * 2

            client.place(
                screen_rect.x + int((screen_rect.width - w) / 2),
                screen_rect.y + int((screen_rect.height - h) / 2),
                w,
                h,
                self.border_width,
                self.border_focus if client.has_focus else self.border_normal,
                margin=self.margin,
            )
            client.unhide()
        else:
            client.hide()
