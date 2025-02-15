<template>
  <div>
    <div class="text-center d-flex align-center justify-end shrink">
      <v-tooltip bottom color="grey darken-1" content-class="py-1">
        <template v-slot:activator="{ on, attrs }">
          <v-btn color="primary" dark class="mr-2" v-bind="attrs" v-on="on">
            <v-icon size="18px" @click="fetchData()">
              {{ icons.mdiRefresh }}
            </v-icon>
          </v-btn>
        </template>
        <span class="white--text text-caption">Refresh</span>
      </v-tooltip>
      <v-btn color="primary" @click="confirm">
        Execute
      </v-btn>
    </div>
    <v-card class="mt-5 grow pa-4 d-flex flex-column">
      <div v-if="pageLoading" class="ma-auto">
        <v-progress-circular
          indeterminate
          color="primary"
        />
      </div>

      <template v-else>
        <div v-if="!responseData.length" class="ma-auto">
          No data available
        </div>
        <template v-else>
          <div
            v-for="(alter, index) in responseData"
            :key="index"
            :class="{ 'mt-5': index !== 0 }"
          >
            <template v-if="alter.Query">
              <code>
                {{ alter.Query }}
              </code>

              <div class="mt-2">
                <div class=" pa-1 rounded p-comment">
                  {{ alter.Changes }}
                </div>
              </div>

              <v-divider class="mt-5" />
            </template>

            <template v-else>
              <code>
                {{ alter }}
              </code>
            </template>
          </div>
          </v-card-text>
        </template>
      </template>
      <CoreConfirmation ref="confirmationModal" />
    </v-card>
  </div>
</template>

<script lang="ts">
import { Component, Vue, Ref } from 'nuxt-property-decorator'
import { mdiRefresh, mdiLoading } from '@mdi/js'
import CoreConfirmation from '~/components/core/Confirmation.vue'

type IResponseData = {
  Query: string,
  Change: string,
}

@Component({
  middleware ({ app, redirect }) {
    if (!app.$config.showRedisSearch) {
      return redirect('/')
    }
  }
})
export default class RedisSearchAlters extends Vue {
  async fetch () {
    await this.fetchData()
  }

  icons = {
    mdiRefresh,
    mdiLoading
  }

  responseData:IResponseData[] = []
  pageLoading = false
  loading = {}
  @Ref('confirmationModal') readonly confirmationModal!:CoreConfirmation

  async fetchData () {
    this.pageLoading = true

    await this.$axios
      .get('/dev/redis-search/alters/')
      .then((response) => {
        this.responseData = response.data
      })
      .catch((error) => {
        console.error(error)
      }).then(() => {
        this.pageLoading = false
      })
  }

  async execute () {
    await this.$axios
      .get('/dev/redis-search/alters/?force=1')
      .then((response) => {
        this.responseData = response.data
        this.$notification.show({
          type: 'success',
          message: 'Success'
        })
      })
      .catch((error) => {
        console.error(error)
        this.$notification.show({
          type: 'error',
          message: error
        })
      })
      .then(() => {})
  }

  confirm () {
    this.confirmationModal
      .show({
        title: 'Wait!!!',
        message: 'Are you sure you want to proceed? It cannot be undone.'
      })
      .then((result: any) => {
        if (result) {
          this.execute()
        }
      })
  }
}
</script>

<style lang="scss" scoped>
$primary: var(--v-primary-base);

.p-comment {
  background: rgba(0, 155, 212, .1);
  font-size: 10px;
}
</style>
