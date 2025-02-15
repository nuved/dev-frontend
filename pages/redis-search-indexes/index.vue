<template>
  <div>
    <div class="d-flex">
      <h2>Redis Search Indexes</h2>
      <v-spacer />
      <v-btn color="primary" :loading="loadingAll" :disabled="loadingAll" @click="confirmAll()">
        Reindex All
      </v-btn>
    </div>
    <v-divider class="my-4" />
    <div>
      <v-data-table
        :headers="headers"
        :items="indexesComputed"
        :items-per-page="-1"
        hide-default-header
        hide-default-footer
        class="d-inline-block elevation-1 font-weight-bold"
      >
        <template v-slot:item.actions="{ index, item }">
          <v-tooltip bottom color="grey darken-1" content-class="py-1">
            <template v-slot:activator="{ on, attrs }">
              <v-btn
                :to="`/redis-search-indexes/details?name=${item.name}`"
                icon
                dark
                color="primary"
                class="mr-1"
                v-bind="attrs"
                v-on="on"
              >
                <v-icon>
                  {{ icons.mdiInformationOutline }}
                </v-icon>
              </v-btn>
            </template>
            <span class="white--text text-caption">Info</span>
          </v-tooltip>
          <v-tooltip bottom color="grey darken-1" content-class="py-1">
            <template v-slot:activator="{ on, attrs }">
              <v-btn
                :loading="loadingIndex === index || loadingAll"
                :disabled="loadingIndex === index || loadingAll"
                icon
                dark
                color="primary"
                v-bind="attrs"
                v-on="on"
                @click="confirm(item, index)"
              >
                <v-icon>
                  {{ icons.mdiRefresh }}
                </v-icon>
              </v-btn>
            </template>
            <span class="white--text text-caption">Re-Index</span>
          </v-tooltip>
        </template>
      </v-data-table>
    </div>

    <CoreConfirmation ref="confirmationModal" />
  </div>
</template>

<script lang="ts">
import { Component, Vue, Ref } from 'nuxt-property-decorator'
import { mdiInformationOutline, mdiRefresh } from '@mdi/js'
import CoreConfirmation from '~/components/core/Confirmation.vue'

type IItem = {
  [key: string]: string | boolean | number
}

@Component
export default class RedisSearchIndexesParent extends Vue {
  async fetch () {
    await this.$axios
      .get('/dev/redis-search/indexes/')
      .then(({ data }) => {
        if (data) {
          this.indexes = data
        }
      })
      .catch((error) => {
        console.error(error)
      })
  }

  @Ref('confirmationModal') readonly confirmationModal!:CoreConfirmation

  headers = [
    {
      text: 'Index',
      align: 'start',
      sortable: false,
      value: 'name'
    },
    {
      text: '',
      align: 'end',
      sortable: false,
      value: 'actions'
    }
  ]

  indexes = []
  loadingIndex:number | null = null
  loadingAll:boolean = false
  reindexing = {}
  icons = {
    mdiInformationOutline,
    mdiRefresh
  }

  get indexesComputed () {
    return this.indexes.map((i) => {
      return { name: i }
    })
  }

  async reindex (item: IItem, index: number) {
    this.loadingIndex = index

    try {
      await this.$axios.$get(
        `/dev/redis-search/force-reindex/${item.name}/`
      )

      this.$notification.show({
        type: 'success',
        message: 'Success'
      })
    } catch (error) {
      console.error(error)
      this.$notification.show({
        type: 'error',
        message: error
      })
    } finally {
      this.loadingIndex = null
    }
  }

  async reindexAll () {
    this.loadingAll = true

    try {
      await this.$axios.$get(
        '/dev/redis-search/force-reindex-all/'
      )

      this.$notification.show({
        type: 'success',
        message: 'Success'
      })
    } catch (error) {
      console.error(error)
      this.$notification.show({
        type: 'error',
        message: error
      })
    } finally {
      this.loadingAll = false
    }
  }

  confirm (item: IItem, index: number) {
    this.confirmationModal
      .show({
        title: 'Wait!!!',
        message: 'Are you sure you want to proceed? It cannot be undone.'
      })
      .then((result) => {
        if (result) {
          this.reindex(item, index)
        }
      })
  }

  confirmAll () {
    this.confirmationModal
      .show({
        title: 'Wait!!!',
        message: 'Are you sure you want to proceed? It cannot be undone.'
      })
      .then((result) => {
        if (result) {
          this.reindexAll()
        }
      })
  }
}
</script>
