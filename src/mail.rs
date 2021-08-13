use std::str;

use lettre::message::header::ContentType;
use lettre::transport::smtp::authentication;
use lettre::{Message, SmtpTransport, Transport};

fn get_mailer(smtp: Smtp) -> Result<SmtpTransport, String> {
    let mut smtp_transport_builder = SmtpTransport::relay(&smtp.server)
        .map_err(|err| {
            format!(
                "Could not create smtp transport with relay '{}'. Error: {}",
                smtp.server, err
            )
        })?
        .port(smtp.port);
    if let Some(credentials) = smtp.credentials {
        let username = if let Some(username_from_options) = credentials.username {
            username_from_options
        } else {
            smtp.email
        };
        let creds = authentication::Credentials::new(username, credentials.password);
        smtp_transport_builder = smtp_transport_builder.credentials(creds);
    }
    Ok(smtp_transport_builder.build())
}

pub fn send_mail(
    simulate: bool,
    email_address: &str,
    subject: &str,
    message_body: &str,
    smtp: Smtp,
) -> Result<(), String> {
    if simulate {
        println!("----------------------");
        println!(
            "Would be sending e-mail message to: {}\nSubject: {}\nBody:\n{}\n----------------------",
            email_address, subject, message_body
        );
    } else {
        printlnv!("Preparing e-mail...");
        let email = Message::builder()
            .header(ContentType::TEXT_HTML)
            .from(smtp.email.parse().map_err(|err| {
                format!(
                    "Could not convert email for 'from' from text '{}'. Error: {}",
                    smtp.email, err
                )
            })?)
            .to(email_address.parse().map_err(|err| {
                format!(
                    "Could not convert email for 'to' from text '{}'. Error: {}",
                    email_address, err
                )
            })?)
            .subject(subject)
            .body(message_body.to_owned())
            .map_err(|err| format!("Error when creating email: {}", err))?;
        printlnv!("Preparing mailer...");
        let mailer = get_mailer(smtp)?;
        printlnv!(
            "Sending e-mail message to: {}\nSubject: {}\nBody:\n{}",
            email_address,
            subject,
            message_body
        );
        let result = mailer.send(&email);
        if let Err(err) = result {
            printlnv!("E-mail message was NOT sent successfully.\nError:\n{}", err);
            return Err("Could not send email.".to_owned());
        } else {
            printlnv!("E-mail message was sent successfully.");
        }
    }
    Ok(())
}

#[derive(Debug)]
pub struct Smtp {
    pub server: String,
    pub email: String,
    pub port: u16,
    pub credentials: Option<Credentials>,
}

#[derive(Debug)]
pub struct Credentials {
    pub username: Option<String>,
    pub password: String,
}
