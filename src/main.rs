#[macro_use]
mod macros;
mod echo;
mod mail;
use std::env;

use handlebars::Handlebars;

static mut VERBOSE: bool = false;

fn main() {
    match do_work() {
        Ok(_) => println!("Done!"),
        Err(err) => println!("Failed. Error:\n{}", err),
    };
}

fn do_work() -> Result<(), String> {
    let mut handlebars = Handlebars::new();
    handlebars
        .register_template_string(
            "t1",
            "<p>Hello, {{ name }}!</p>\n<p>{{ message }}</p>".to_owned(),
        )
        .map_err(|err| format!("Error when parsing template: {}", err))?;
    let mut destination = std::collections::HashMap::new();
    destination.insert("name", "Giovanni");
    destination.insert("message", "Hello there!");
    let body = handlebars
        .render("t1", &destination)
        .map_err(|err| format!("Error when rendering template: {}", err))?;
    let simulate = env::args().count() <= 1;
    mail::send_mail(
        simulate,
        "giggio@giggio.net",
        "A subject",
        &body,
        &mail::Smtp {
            email: "user@aaaaaaaaaaaaaaaaaaaaaaaa.com".to_owned(),
            port: 465,
            server: "mail.aaaaaaaaaaaaaaaaaaaaaaaa.com".to_owned(),
            credentials: None,
        },
    )?;
    echo::echo("Hello world")?;
    Ok(())
}
