using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;

using Microsoft.Lync.Model;
using Microsoft.Lync.Model.Extensibility;
using System.Runtime.InteropServices;
using Microsoft.Lync.Model.Conversation;
using Microsoft.Lync.Model.Conversation.AudioVideo;
using System.Net;
using System.IO;


namespace lync_monitor_forms
{

    public partial class Form1 : Form
    {

        private LyncClient _LyncClient;

        public Form1()
        {
            InitializeComponent();
            _LyncClient = LyncClient.GetClient();

            // update status to green
            _LyncClient.Self.Contact.ContactInformationChanged += Contact_ContactInformationChanged;

            // handler on new conversation start
            _LyncClient.ConversationManager.ConversationAdded += ConversationManager_ConversationAdded;

            // handler on conversation end
            _LyncClient.ConversationManager.ConversationRemoved += ConversationManager_ConversationRemoved; 
        }

        /// <summary>
        /// Sends a publication request and handles any exceptions raised.
        /// </summary>
        /// <param name="publishData">Dictionary. Information to be published.</param>
        /// <param name="PublishId">string. Unique publication identifier.</param>
        private void PublishStatusChangeRequest(
           Dictionary<PublishableContactInformationType, object> publishData,
            string PublishId)
        {
            object publishState = (object)PublishId;
            object[] _PublishAsyncState = { _LyncClient.Self, publishState };
            try
            {
                _LyncClient.Self.BeginPublishContactInformation(
                    publishData,
                    PublicationCallback,
                    _PublishAsyncState);
            }
            catch (COMException ce)
            {
                MessageBox.Show("publish COM exception: " + ce.ErrorCode.ToString());
            }
            catch (ArgumentException ae)
            {
                MessageBox.Show("publish Argument exception: " + ae.Message);
            }
        }

        /// <summary>
        /// Handles event raised when the presence of a contact has been updated
        /// </summary>
        /// <param name="source">Contact. Contact instance whose presence is updated</param>
        /// <param name="data">PresenceItemsChangedEventArgs. Collection of presence item types whose values have been updated.</param>
        void Contact_ContactInformationChanged(object source, ContactInformationChangedEventArgs e)
        {
            if (((Contact)source) == _LyncClient.Self.Contact)
            {
                PublishFreeAvailability();
            }
        }


        /// <summary>
        /// Publishes an update to a personal note
        /// </summary>
        /// <param name="newNote">string. The new personal note text.</param>
        public void PublishFreeAvailability()
        {
            //Each element of this array must contain a valid enumeration. If null array elements 
            //are passed, an ArgumentException is raised.
            Dictionary<PublishableContactInformationType, object> publishData = new Dictionary<PublishableContactInformationType, object>();
            //publishData.Add(PublishableContactInformationType.PersonalNote, newNote);
            publishData.Add(PublishableContactInformationType.Availability, ContactAvailability.Free);

            //Helper method is found in the next example.
            PublishStatusChangeRequest(publishData, "Personal Note and Availability");
        }

        /// <summary>
        /// callback method called by BeginPublishContactInformation()
        /// </summary>
        /// <param name="ar">IAsyncResult. Asynchronous result state.</param>
        private void PublicationCallback(IAsyncResult ar)
        {
            if (ar.IsCompleted)
            {
                object[] _asyncState = (object[])ar.AsyncState;
                ((Self)_asyncState[0]).EndPublishContactInformation(ar);
            }
        }

        void ConversationManager_ConversationRemoved(object sender, ConversationManagerEventArgs data)
        {


        }

        /// <summary>
        /// Handles ConversationAdded state change event raised on ConversationsManager
        /// </summary>
        /// <param name="source">ConversationsManager The source of the event.</param>
        /// <param name="data">ConversationsManagerEventArgs The event data. The incoming Conversation is obtained here.</param>
        void ConversationManager_ConversationAdded(object sender, ConversationManagerEventArgs data)
        {
            // Register for Conversation state changed events.
            data.Conversation.ParticipantAdded += Conversation_ParticipantAdded;
            //data.Conversation.StateChanged += Conversation_ConversationChangedEvent;
        }

        /// <summary>
        /// ParticipantAdded callback handles ParticpantAdded event raised by Conversation
        /// </summary>
        /// <param name="source">Conversation Source conversation.</param>
        /// <param name="data">ParticpantCollectionEventArgs Event data</param>
        void Conversation_ParticipantAdded(Object source, ParticipantCollectionChangedEventArgs data)
        {
            if (data.Participant.IsSelf == false)
            {
                if (((Conversation)source).Modalities.ContainsKey(ModalityTypes.InstantMessage))
                {
                    string contact = data.Participant.Contact.Uri;
                    ((InstantMessageModality)data.Participant.Modalities[ModalityTypes.InstantMessage]).InstantMessageReceived += myInstantMessageModality_MessageReceived;
                    //((InstantMessageModality)data.Participant.Modalities[ModalityTypes.InstantMessage]).IsTypingChanged += myInstantMessageModality_ComposingChanged;
                }
            }
        }

        void myInstantMessageModality_MessageReceived(object sender, MessageSentEventArgs data)
        {
            notifyServer();
        }

        void Conversation_ConversationChangedEvent(object sender, ConversationManagerEventArgs data)
        {
        }

        void notifyServer()
        {
            HttpWebRequest httpWReq = (HttpWebRequest)WebRequest.Create("https://api.backendless.com/v1/messaging/Default");
            httpWReq.Proxy = new WebProxy("localhost", 4545);

            ASCIIEncoding encoding = new ASCIIEncoding();
            string postData = "{ \"message\":\"this is a private message!\", \"pushPolicy\":\"ONLY\", \"pushSinglecast\": [ \"receiver-device-id\" ], \"headers\":{ \"android-ticker-text\", \"You just got a private push notification!\", \"android-content-title\", \"This is a notification title\", \"android-content-text\", \"Push Notifications are cool\" } }";
            byte[] data = encoding.GetBytes(postData);

            httpWReq.Method = "POST";
            httpWReq.ContentType = "application/x-www-form-urlencoded";
            httpWReq.Headers.Add("application-id:E1E22A18-4783-155C-FF85-74A366075600");
            httpWReq.Headers.Add("secret-key:E1E22A18-4783-155C-FF85-74A366075600");
            httpWReq.ContentLength = data.Length;

            using (Stream stream = httpWReq.GetRequestStream())
            {
                stream.Write(data, 0, data.Length);
            }

            try
            {
                HttpWebResponse response = (HttpWebResponse)httpWReq.GetResponse();
                string responseString = new StreamReader(response.GetResponseStream()).ReadToEnd();

                MessageBox.Show(responseString);
            }
            catch (WebException e)
            {
                MessageBox.Show(e.Message + "\n" + e.ToString());
            }

            
        }

        private void button1_Click(object sender, EventArgs e)
        {
            notifyServer();
        }

        

    }
}
