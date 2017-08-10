Bobot::Commander.deliver(
  body: {
    recipient: { id: "1597211973630845" },
    message: {
      quick_replies: [
        {
          content_type: "text",
          title: "title1",
          payload: "SUPPLEMENT_1",
        },
        {
          content_type: "text",
          title: "title2",
          payload: "PAYLOAD_1",
        },
      ],
      text: "qq",
      attachment: {
        type: "template",
        payload: {
          template_type: "button",
          text: "your text",
          buttons: [
            {
              type: "postback",
              title: "Confirm",
              payload: "USER_DEFINED_PAYLOAD",
            },
          ],
        },
      },
    },
  },
  query: {
    access_token: "EAAJOpt2MQbMBAGbyVi7EAgVeIaLoINIjnJeF9tK7qZBA8t4fm1SZAedZAgSN1rY7lAkyDZAGySs3AZAn9zqL00hvAJnUV18ZAprv7CVPOREMZC24jdIa72MEg2ZCQXCz60BoZA9AexNeSIhkiNMiVjHUy6b8Mwky2BvG11BxXoVqJsAZDZD",
  },
)
